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
id/index.qmd              Indonesian landing page
id/pengadaan.qmd          Indonesian procurement practice page
id/tulisan.qmd            Indonesian essays (excluded from the build for now)
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

**Indonesian pages.** `id/` is a separate short section for the Indonesian
procurement audience, not a translation. It deliberately carries no dated record
of its own: roles, decrees, and dates live only on the English pages, so the two
languages cannot state different facts. Keep it that way when editing.

**Procurement essays.** Both the English Insights page and the Indonesian
Tulisan page are written but excluded from the build until the first essay
exists. To turn it on, remove the
`"!procurement/insights.qmd"` exclusion in `_quarto.yml` and uncomment the
Insights section at the foot of `procurement/index.qmd`. Start an essay from
`procurement/insights/_post-template.qmd`.

**New entries.** Copy an existing `.paper` block in `research.qmd` or an
`.entry` block in `professional.qmd`.

## Custom domain

billytulungen.com is registered but not yet live. At the registrar, create four
A records on the apex host pointing to 185.199.108.153, 185.199.109.153,
185.199.110.153, and 185.199.111.153, and a CNAME for `www` pointing to
`billytulungen.github.io.`

Then run the switch-over, which refuses to act until DNS actually resolves to
all four addresses. Committing a `CNAME` before that would make GitHub redirect
the .github.io address to a domain that does not answer, taking the site off the
air at both addresses.

```bash
./files/src/enable-domain.sh
```
