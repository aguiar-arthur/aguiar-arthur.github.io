# Repository guide

This repository is Arthur Aguiar's personal blog, built as a static site with
Jekyll. It uses the `no-style-please` theme (light and dark follow the visitor's system) and is
published at `https://aguiar-arthur.github.io`.

Detailed component, layout, papers and asset documentation is in [`docs/`](docs/README.md).

## Tooling and libraries

- Ruby and Bundler manage the site dependencies; use `bundle exec` for Jekyll
  commands.
- Jekyll `~> 4.4.0` builds the site.
- `no-style-please` supplies the base theme and layouts.
- `jekyll-feed` generates the feed.
- Markdown is rendered by Kramdown with GitHub Flavored Markdown input.
- Code blocks are highlighted with Rouge. Its stylesheet is loaded globally
  from `assets/css/rouge.css` by the local head include.
- Mathematical notation is rendered client-side by MathJax. Add
  `{% include mathjax.html %}` to a page that uses TeX math such as `$$...$$`.

Useful local commands (run them from the repository root):

```sh
bundle install
bundle exec jekyll serve
bundle exec jekyll build
ruby bin/check-content   # validates front matter, references and taxonomy
ruby bin/check-site      # broken links/images in the built _site/ (gem install html-proofer first)
git config core.hooksPath .githooks   # once per clone: pre-commit runs the validator, pre-push the site check
```

Changing `_config.yml` requires restarting `bundle exec jekyll serve` because
Jekyll does not reload that file automatically.

## Repository layout

| Path | Purpose |
| --- | --- |
| `_posts/` | Long-form blog posts, organized by subject. |
| `_annotations/` | Study notes and exercise annotations, organized by course/topic. |
| `_books/` | Notes and reviews about books, organized by subject. |
| `_papers/` | Grouped documents: `_papers/<group>/index.md` (layout `group`) plus the group's PDFs. |
| `assets/pdfs/` | Source PDFs for annotations. This directory is published as static files. |
| `assets/images/posts/` | Images used by regular posts. |
| `assets/images/annotations/` | Images used by annotations. |
| `_includes/` | Reusable Liquid snippets, including the PDF, MathJax, warning, list, content-index, and head includes. |
| `assets/js/content-index.js` | Client-side search and 10-item pagination for the three principal collection indexes. |
| `_layouts/` | `default`, `post`, `home` and `group` (local; they replace the theme's). |
| `_data/` | YAML data used by templates, currently social links. |
| `pages/` | Standalone pages (`pages/{posts,annotations,books,papers}/` index, category and tag pages, and `pages/about/`). Each declares its own `permalink`. |
| `_config.yml` | Site metadata, collection behavior, Markdown settings, and permalinks. |
| `docs/` | Project documentation; excluded from the published site. |
| `bin/check-content` | Content validator (Ruby, standard library); also run in CI. |
| `_site/` | Generated output. Treat as build artefacts; edit source files instead. |

## Content placement and front matter

All content documents use YAML front matter and inherit `layout: post` from
`_config.yml` (explicitly setting it is fine and common in existing files).
Use a quoted `title`, a parsable `date`, `categories` (a list), and optional `tags`.
The date must match the date in the file name. Licensing front matter: every page defaults to "based on third-party material; only the author's own contribution is
CC BY 4.0" (the blog is study notes and reviews). Optional `source:` names the material's author, `license_mode: own` marks a page
that is entirely the author's, and `license:` replaces the footer notice. Code is MIT. Run `ruby bin/check-content` after editing content; it fails on
missing fields or references to missing files and warns about inconsistencies.

URLs derive from the file, not from the title: renaming or moving a file (or changing a post's `date`) changes its
URL and nothing redirects the old one, so do not rename content without a reason.

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

The date part comes from the front-matter `date` and `slug` from the file name.

Posts are listed on `pages/posts/principal.html`; the tag and category pages live in
`pages/posts/`. The principal page uses
`_includes/content-index.html`, which displays 10 items per page and filters
title, date, category, and tag text through `assets/js/content-index.js`.

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

They are listed by `pages/annotations/principal.html` and are sorted there by date,
newest first. The list is paginated and searchable through the shared
content-index component.

### Book notes

Place book-related writing in `_books/<topic>/` using the regular dated Markdown
filename convention. Book pages render to:

```text
/books/<source path without extension>/
```

They are listed by `pages/books/principal.html`, sorted newest first, with the same
10-item pagination and search behavior as posts and annotations.

### Papers

`pages/papers/principal.html` lists the paper groups; opening one shows the group page
(`_layouts/group.html`): language banner (when `lang` is not `en`), the `description`
text, and a list of documents built by `_includes/file-list.html`.

```text
_papers/monads/index.md   # layout: group, permalink: /papers/monads/
_papers/monads/*.pdf      # listed only if declared in the front matter `files:`
```

```yaml
files:
  - file: "document.pdf"
    title: "Display title"
```

Only the declared files are listed, in the declared order. An entry `- divider: "Any text"` inserts a section
heading between documents.

The layout and include are generic and can be reused for other folder-of-documents pages.

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

`pdf-viewer.html` embeds the PDF responsively and provides an **Open PDF in New
Tab** fallback link. Its optional `height` argument controls the embedded
viewer height and defaults to `800px`. Use a site-root-relative path beginning
with `/assets/pdfs/`; `relative_url` keeps the generated links correct if the
site later uses a non-empty `baseurl`.

Keep the Markdown annotation and its PDF together conceptually: when renaming
or moving one, update the other and update the Liquid include path. There is no
automatic filename mapping or validation between them.

## Authoring conventions

- Write content in Markdown and use Liquid includes only for shared behavior.
- Keep taxonomy consistent with the existing capitalized category names and
  descriptive tag values.
- Use `relative_url` for internal template links, as the existing index pages
  do.
- Keep custom styling minimal and theme-compatible; shared site and syntax
  styles live in `assets/css/site.css` and `assets/css/rouge.css`.
- Do not hand-edit generated files in `_site/`; rebuild instead.
