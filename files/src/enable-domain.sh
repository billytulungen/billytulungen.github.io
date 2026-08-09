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

doh () {  # $1 = name, $2 = type -> newline-separated answers
  curl -s --max-time 20 "https://dns.google/resolve?name=$1&type=$2" \
    | /usr/bin/python3 -c "
import json,sys
d=json.load(sys.stdin)
print('\n'.join(a['data'] for a in (d.get('Answer') or [])))
"
}

# Two different failures need two different fixes, so tell them apart: a domain
# with no nameservers cannot have A records at all.
ns=$(doh "$DOMAIN" NS)
if [[ -z "$ns" ]]; then
  cat >&2 <<EOF

The domain has no working nameservers yet, so no DNS record of any kind can
resolve. Fix that first; adding A records before this will do nothing.

At Rumahweb: Domain > billytulungen.com > Pengaturan > Pengaturan Nameserver,
and set all four:

  nsid1.rumahweb.com
  nsid2.rumahweb.net
  nsid3.rumahweb.biz
  nsid4.rumahweb.org

Also check Pengaturan > DNSSEC is off. DNSSEC left half-configured produces
exactly this failure.

Then wait for the change to propagate and run this script again; it will tell
you what to do next.
EOF
  exit 1
fi

resolved=$(curl -s --max-time 20 "https://dns.google/resolve?name=${DOMAIN}&type=A" \
  | /usr/bin/python3 -c "
import json,sys
d=json.load(sys.stdin)
print(' '.join(sorted(a['data'] for a in (d.get('Answer') or []) if a.get('type')==1)))
")

if [[ -z "$resolved" ]]; then
  cat >&2 <<EOF

Nameservers answer, but $DOMAIN has no A records yet.

At Rumahweb: Domain > billytulungen.com > Pengaturan > Manajemen DNS, then
Add New Record four times, type A, host "@" (or leave the name blank):

  ${EXPECTED[0]}
  ${EXPECTED[1]}
  ${EXPECTED[2]}
  ${EXPECTED[3]}

and once more, type CNAME, host "www", value:
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
