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

**A new procurement essay.** The Insights page is written but held back from
the build: an index of six unwritten essays reads worse than no page at all. To
turn it on, delete the `"!procurement/insights.qmd"` exclusion in `_quarto.yml`
and uncomment the Insights section at the foot of `procurement/index.qmd`.

To write one, copy `procurement/insights/_post-template.qmd` to
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

- [x] ~~Profile photograph~~ — `assets/img/profile.jpg`, cropped to 4:5 and
      resized to 800x1000 for retina. Source was an AI-generated portrait; if
      you later shoot a real headshot, drop it in at the same path and size.
- [x] ~~Favicon~~ — `assets/img/favicon.png`, a BT monogram in the site accent
      colour. Source: the PIL snippet in the commit that added it.
- [x] ~~Public CV PDF~~ — `files/cv-billy-tulungen.pdf`, built from
      `files/src/cv.tex`. Edit the `.tex` and recompile; never hand-edit the
      PDF:

      ```bash
      cd files/src && pdflatex cv.tex && cp cv.pdf ../cv-billy-tulungen.pdf
      ```

      It deliberately omits NIK, NIP, NPWP, bank details, date of birth, home
      address, and mobile number, and gives referees' institutional emails only.
      Do **not** publish the CVs in `~/Downloads`, which carry all of the above.
- [x] ~~Paper 1 draft~~ — linked from Home and Research. The draft is still
      moving, so refresh it whenever you rebuild `main.pdf`:

      ```bash
      ./files/src/update-paper.sh && quarto render
      ```

      The script copies the PDF and stamps its modification date into
      `_variables.yml`, which feeds the "This version" label. The label can
      therefore never disagree with the file a reader downloads — so do not
      edit `_variables.yml` by hand.
- [x] ~~Google Scholar and ORCID~~ — in the footer and on the CV, both web and
      PDF.
- [x] ~~Presentations and refereeing~~ — no talks yet, so the Presentations
      section was removed rather than left empty. Refereeing for *Jurnal
      Kebijakan Ekonomi* is on the CV and the Professional page. Both live in
      `cv.qmd` **and** `files/src/cv.tex`; change them together.
- [ ] Set `site-url` in `_quarto.yml` to the final domain.

## Publishing to GitHub Pages

```bash
gh repo create billytulungen.github.io --public --source=. --push
```

Then in the repository: **Settings → Pages → Build and deployment → Source:
GitHub Actions**. Every push to `main` rebuilds and redeploys via
`.github/workflows/publish.yml`.

For a custom domain, add a `CNAME` file containing the bare domain, point the
domain's DNS at GitHub Pages, and update `site-url` in `_quarto.yml`.
