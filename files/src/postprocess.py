#!/usr/bin/env python3
"""Add canonical URLs, a Person record, and hreflang to the rendered site.

Quarto emits Open Graph and a sitemap from `site-url`, but not canonical links
or structured data, so this runs as a post-render step. It rewrites files in
_site only; nothing here touches source.

Idempotent: every insertion checks for its own marker first, so re-rendering
does not stack duplicates.
"""

import pathlib
import re
import json

SITE = "https://billytulungen.com"
ROOT = pathlib.Path("_site")

# The Indonesian section is not a translation of the English one, so hreflang is
# claimed only where the two genuinely serve the same purpose: the landing page.
# Marking the rest as alternates would tell search engines the pages carry the
# same content, which they do not.
ALTERNATES = {
    "index.html": "id/index.html",
    "id/index.html": "index.html",
}

PERSON = {
    "@context": "https://schema.org",
    "@type": "Person",
    "name": "Billy Thandy Tulungen",
    "givenName": "Billy",
    "familyName": "Tulungen",
    "url": SITE,
    "email": "mailto:billy.thandy21@ui.ac.id",
    "jobTitle": "PhD Candidate in Economics",
    "affiliation": {
        "@type": "CollegeOrUniversity",
        "name": "Universitas Indonesia",
        "department": {
            "@type": "Organization",
            "name": "Department of Economics, Faculty of Economics and Business",
        },
    },
    "knowsAbout": [
        "Development economics",
        "Urban and regional economics",
        "Political economy",
        "Public procurement",
    ],
    "sameAs": [
        "https://orcid.org/0000-0001-5480-1426",
        "https://scholar.google.com/citations?user=LchRWJsAAAAJ",
        "https://www.linkedin.com/in/billytulungen",
        "https://x.com/billythandy",
    ],
}


def url_for(rel: str) -> str:
    """Canonical address for a rendered file. Directory indexes drop the file."""
    if rel == "index.html":
        return SITE + "/"
    if rel.endswith("/index.html"):
        return f"{SITE}/{rel[: -len('index.html')]}"
    return f"{SITE}/{rel}"


def main() -> None:
    if not ROOT.is_dir():
        raise SystemExit("run from the repository root, after quarto render")

    touched = 0
    for path in sorted(ROOT.rglob("*.html")):
        rel = path.relative_to(ROOT).as_posix()
        if rel == "404.html":          # never a canonical destination
            continue

        html = path.read_text(encoding="utf-8")
        head_at = html.find("</head>")
        if head_at < 0:
            continue

        block = ""

        if 'rel="canonical"' not in html:
            block += f'\n<link rel="canonical" href="{url_for(rel)}">'

        other = ALTERNATES.get(rel)
        if other and "hreflang" not in html:
            this_lang = "id" if rel.startswith("id/") else "en"
            other_lang = "en" if this_lang == "id" else "id"
            block += (
                f'\n<link rel="alternate" hreflang="{this_lang}" href="{url_for(rel)}">'
                f'\n<link rel="alternate" hreflang="{other_lang}" href="{url_for(other)}">'
                f'\n<link rel="alternate" hreflang="x-default" href="{url_for("index.html")}">'
            )

        # The Person record belongs on the landing pages, not on every page.
        if rel in ("index.html", "id/index.html") and "schema.org" not in html:
            block += (
                '\n<script type="application/ld+json">'
                + json.dumps(PERSON, ensure_ascii=False, separators=(",", ":"))
                + "</script>"
            )

        if block:
            path.write_text(html[:head_at] + block + "\n" + html[head_at:],
                            encoding="utf-8")
            touched += 1

    print(f"postprocess: {touched} file diperbarui")


if __name__ == "__main__":
    main()
