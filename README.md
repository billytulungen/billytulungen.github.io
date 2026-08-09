# billytulungen.github.io

Personal academic website of Billy Tulungen, PhD candidate in Economics at
Universitas Indonesia.

Built with [Quarto](https://quarto.org) and deployed to GitHub Pages by the
workflow in `.github/workflows/publish.yml`. Every push to `main` rebuilds and
redeploys.

## Local development

```bash
quarto preview          # live-reloading preview
quarto render           # full build into _site/
```

## Layout

```
_quarto.yml               site config: navbar, footer, theme
_variables.yml            generated; holds the working paper's version date
styles.scss               all visual design
index.qmd                 home
research.qmd              working papers, work in progress, publications, grants
procurement/index.qmd     public procurement practice
procurement/insights.qmd  essay index (excluded from the build for now)
teaching.qmd              graduate teaching and professional training
professional.qmd          government service, national roles, service
cv.qmd                    CV, with a link to the PDF
about.qmd                 narrative bio
assets/img/               photograph, favicon, figures
files/                    downloadable PDFs
files/src/                sources for the generated PDFs
```

## Maintenance

**Working paper.** The draft is edited elsewhere and copied in on demand. The
script stamps the PDF's own modification date into `_variables.yml`, which feeds
the "This version" label on the Research page, so the label cannot disagree with
the file a reader downloads. Do not edit `_variables.yml` by hand.

```bash
./files/src/update-paper.sh && quarto render
```

**CV.** Edit `files/src/cv.tex` and recompile; never hand-edit the PDF.

```bash
cd files/src && pdflatex cv.tex && pdflatex cv.tex && cp cv.pdf ../cv-billy-tulungen.pdf
```

**Procurement essays.** The Insights page is written but excluded from the build
until the first essay exists. To turn it on, remove the
`"!procurement/insights.qmd"` exclusion in `_quarto.yml` and uncomment the
Insights section at the foot of `procurement/index.qmd`. Start an essay from
`procurement/insights/_post-template.qmd`.

**New entries.** Copy an existing `.paper` block in `research.qmd` or an
`.entry` block in `professional.qmd`.

## Custom domain

Add a `CNAME` file containing the bare domain, point the domain's DNS at GitHub
Pages, and update `site-url` in `_quarto.yml`.
