# billytulungen.com — personal academic website

Quarto website. Source lives here; the rendered site goes to `_site/` (gitignored)
and is published to GitHub Pages by CI.

## Requirements

Quarto is installed user-locally at `~/.local/opt/quarto`, with a symlink at
`~/.local/bin/quarto`. Add it to your PATH once:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

To install it system-wide instead (requires your admin password):

```bash
brew install --cask quarto
```

## Daily use

```bash
cd ~/website
quarto preview          # live-reloading local preview
quarto render           # full build into _site/
```

## Layout

```
_quarto.yml               site config: navbar, footer, theme
styles.scss               all visual design lives here
index.qmd                 Home
research.qmd              Working papers, WIP, publications, dissertation
procurement/
  index.qmd               Public Procurement: expertise, roles, engagements
  insights.qmd            Essay index
  insights/               One .qmd per essay
    _post-template.qmd    Copy this to start a new essay
teaching.qmd              University teaching + professional training
professional.qmd          Government service, advisory, professional service
cv.qmd                    CV summary + PDF download
about.qmd                 Narrative bio
assets/img/               Photos, favicon
files/                    Downloadable PDFs (CV, papers, slides)
```

## Adding content

**A new procurement essay.** Copy `procurement/insights/_post-template.qmd` to
`procurement/insights/YYYY-MM-DD-slug.qmd`, write it, then move its title on
`procurement/insights.qmd` out of "In preparation" into a linked entry. Once
there are several essays it is worth converting `insights.qmd` to a Quarto
listing — add to its front matter:

```yaml
listing:
  contents: insights
  type: default
  sort: "date desc"
  fields: [date, title, description]
```

**A new paper.** Copy a `.paper` block in `research.qmd`. Put the PDF in
`files/` and link it from `.paper-links`.

**A new role or position.** Copy an `.entry` block in `professional.qmd` or
`procurement/index.qmd`.

## Before the first publish

- [ ] Add a professional photograph at `assets/img/profile.jpg`, then replace
      the `.photo-placeholder` div in `index.qmd` with
      `![](assets/img/profile.jpg)`.
- [ ] Add `assets/img/favicon.png` (512×512 works fine).
- [ ] Export a **public** CV to `files/cv-billy-tulungen.pdf`. Strip NIK, NIP,
      NPWP, bank account, date of birth, home address, and personal mobile
      number first — the CVs in `~/Downloads` contain all of these.
- [ ] Fill in the real Google Scholar / ORCID / GitHub / LinkedIn URLs in the
      `page-footer` block of `_quarto.yml`, and delete the placeholder ones you
      do not have.
- [ ] Set `site-url` in `_quarto.yml` to the final domain.
- [ ] Delete the two `.note` editorial blocks (in `cv.qmd` and `teaching.qmd`)
      once their content is in place.

## Publishing to GitHub Pages

```bash
gh repo create billytulungen.github.io --public --source=. --push
```

Then in the repository: **Settings → Pages → Build and deployment → Source:
GitHub Actions**. Every push to `main` rebuilds and redeploys via
`.github/workflows/publish.yml`.

For a custom domain, add a `CNAME` file containing the bare domain, point the
domain's DNS at GitHub Pages, and update `site-url` in `_quarto.yml`.
