#!/usr/bin/env bash
#
# Switch the site over to the custom domain, but only once DNS is actually
# ready.
#
# Order matters here. The moment a CNAME file lands in the published artifact,
# GitHub starts redirecting billytulungen.github.io to the custom domain. If the
# domain does not resolve yet, the site is unreachable at both addresses. So
# this script refuses to do anything until the apex domain resolves to all four
# GitHub Pages addresses.
#
# Run from the repository root:
#   ./files/src/enable-domain.sh
#
# It is safe to run repeatedly: it exits without changing anything if DNS is not
# ready.

set -euo pipefail

DOMAIN="billytulungen.com"
REPO="billytulungen/billytulungen.github.io"

# GitHub Pages apex addresses, per GitHub's own documentation.
EXPECTED=(185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153)

echo "Checking DNS for $DOMAIN ..."

# dig is not always available in a sandbox; DNS-over-HTTPS always is.
resolved=$(curl -s --max-time 20 "https://dns.google/resolve?name=${DOMAIN}&type=A" \
  | /usr/bin/python3 -c "
import json,sys
d=json.load(sys.stdin)
print(' '.join(sorted(a['data'] for a in (d.get('Answer') or []) if a.get('type')==1)))
")

if [[ -z "$resolved" ]]; then
  cat >&2 <<EOF

DNS is not ready. $DOMAIN does not resolve to anything yet.

At your registrar, create four A records on the apex (host "@"):
  ${EXPECTED[0]}
  ${EXPECTED[1]}
  ${EXPECTED[2]}
  ${EXPECTED[3]}

and a CNAME record for host "www" pointing to:
  billytulungen.github.io.

Then run this script again. Propagation usually takes minutes but can take
up to a day.
EOF
  exit 1
fi

missing=()
for ip in "${EXPECTED[@]}"; do
  [[ " $resolved " == *" $ip "* ]] || missing+=("$ip")
done

if (( ${#missing[@]} )); then
  echo "DNS resolves to: $resolved" >&2
  echo "Still missing:   ${missing[*]}" >&2
  echo "Add the missing A records and run again." >&2
  exit 1
fi

echo "DNS looks right: $resolved"
echo

# CNAME must be copied into the published site, so it is declared as a project
# resource in _quarto.yml.
echo "$DOMAIN" > CNAME
echo "wrote CNAME"

/usr/bin/python3 - "$DOMAIN" <<'PY'
import pathlib, re, sys
domain = sys.argv[1]
p = pathlib.Path('_quarto.yml'); t = p.read_text()
t = re.sub(r'site-url: "[^"]*"', f'site-url: "https://{domain}"', t, count=1)
if 'resources:' not in t:
    t = t.replace('  output-dir: _site', '  output-dir: _site\n  resources:\n    - CNAME', 1)
p.write_text(t)
print('updated _quarto.yml')
PY

git add -A
git commit -q -m "Serve the site from $DOMAIN"
git push -q origin main
echo "pushed"

gh api -X PUT "repos/$REPO/pages" -f "cname=$DOMAIN" >/dev/null
echo "custom domain set on GitHub Pages"

cat <<EOF

Done. Two things follow on their own:

  1. GitHub provisions a TLS certificate, usually within an hour.
  2. Once it exists, enforce HTTPS:

     gh api -X PUT repos/$REPO/pages -F https_enforced=true

Check the site at https://$DOMAIN
EOF
