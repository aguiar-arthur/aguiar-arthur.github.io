# Repository guide

This repository is Arthur Aguiar's personal blog, built as a static site with
Jekyll. It uses the `no-style-please` theme with a dark appearance and is
published at `https://aguiar-arthur.github.io`.

## Tooling and libraries

- Ruby and Bundler manage the site dependencies; use `bundle exec` for Jekyll
  commands.
- Jekyll `~> 4.4.0` builds the site.
- `no-style-please` supplies the base theme and layouts.
- `jekyll-feed` generates the feed.
- Markdown is rendered by Kramdown with GitHub Flavored Markdown input.
- Code blocks are highlighted with CodeRay through
  `kramdown-syntax-coderay`; its stylesheet lives at
  `assets/css/coderay.css` and can be included with
  `{% include coderay.html %}`.
- Mathematical notation is rendered client-side by MathJax. Add
  `{% include mathjax.html %}` to a page that uses TeX math such as `$$...$$`.

Useful local commands:

```sh
bundle install
bundle exec jekyll serve
bundle exec jekyll build
```

Changing `_config.yml` requires restarting `bundle exec jekyll serve` because
Jekyll does not reload that file automatically.

## Repository layout

| Path | Purpose |
| --- | --- |
| `_posts/` | Long-form blog posts, organized by subject. |
| `_annotations/` | Study notes and exercise annotations, organized by course/topic. |
| `_books/` | Notes and reviews about books, organized by subject. |
| `assets/pdfs/` | Source PDFs for annotations. This directory is published as static files. |
| `assets/images/posts/` | Images used by regular posts. |
| `assets/images/annotations/` | Images used by annotations. |
| `_includes/` | Reusable Liquid snippets, including the PDF, MathJax, CodeRay, warning, and list includes. |
| `_layouts/` | Site-specific layouts; `home.html` is used by the landing page. |
| `_data/` | YAML data used by templates, currently social links. |
| `posts/`, `annotations/`, `books/` | Index, category, and tag pages for the corresponding content streams. |
| `_config.yml` | Site metadata, collection behavior, Markdown settings, and permalinks. |
| `_site/` | Generated output. Treat as build artefacts; edit source files instead. |

## Content placement and front matter

All content documents use YAML front matter and inherit `layout: post` from
`_config.yml` (explicitly setting it is fine and common in existing files).
Use a quoted `title`, a parsable `date`, `categories`, and optional `tags`.

### Regular posts

Place original articles in `_posts/<topic>/`. Use the standard Jekyll filename
format:

```text
_posts/<topic>/YYYY-MM-DD-slug.md
```

Nested topic directories are intentional (for example,
`_posts/mathematics/geometry/` and `_posts/computer-science/assembly/`). The
configured post URLs are:

```text
/posts/YYYY/MM/DD/slug/
```

Posts are listed on `posts/principal.html`; the tag and category pages live in
the same `posts/` directory.

### Annotations

Place course notes, lists, and PDF-backed study material in
`_annotations/<topic>/`, preserving useful subtopics when needed (for example,
`_annotations/programming/clojure/`). Annotation filenames may follow the
existing short-date convention (`YY-MM-DD-slug.md`) or the full-date convention
(`YYYY-MM-DD-slug.md`). The front-matter `date`, rather than the filename,
controls the displayed date and ordering.

Annotations render to:

```text
/annotations/<source path without extension>/
```

They are listed by `annotations/principal.html` and are sorted there by date,
newest first.

### Book notes

Place book-related writing in `_books/<topic>/` using the regular dated Markdown
filename convention. Book pages render to:

```text
/books/<source path without extension>/
```

They are listed by `books/principal.html`, sorted newest first.

## PDFs and annotations

PDFs are source assets, not Jekyll collection documents. Store them beneath
`assets/pdfs/<matching-topic>/`, mirroring the annotation's topic hierarchy
where practical. For example:

```text
_annotations/cdi_one/25-07-15-functions-introduction.md
assets/pdfs/cdi_one/functions_introduction.pdf
```

Link or display the PDF from its annotation with the shared include:

```liquid
{% include pdf-viewer.html file="/assets/pdfs/cdi_one/functions_introduction.pdf" height="800px" %}
```

`pdf-viewer.html` currently renders an **Open PDF in New Tab** link. Its
`height` argument is accepted by existing content but is not used by the
include, so do not expect it to change the output unless the include is updated.
Use a site-root-relative path beginning with `/assets/pdfs/`; this keeps the
generated link correct for the configured empty `baseurl`.

Keep the Markdown annotation and its PDF together conceptually: when renaming
or moving one, update the other and update the Liquid include path. There is no
automatic filename mapping or validation between them.

## Authoring conventions

- Write content in Markdown and use Liquid includes only for shared behavior.
- Keep taxonomy consistent with the existing capitalized category names and
  descriptive tag values.
- Use `relative_url` for internal template links, as the existing index pages
  do.
- Keep custom styling minimal and theme-compatible; shared CodeRay styling
  belongs in `assets/css/coderay.css`.
- Do not hand-edit generated files in `_site/`; rebuild instead.
