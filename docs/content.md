# Writing content

Front matter, file names, URLs, languages, PDFs, licensing and the validator. Templates are described in
[site.md](site.md); tooling in [maintenance.md](maintenance.md).

## Collections and URLs

| Collection | Source | URL |
| --- | --- | --- |
| `posts` | `_posts/<topic>/YYYY-MM-DD-slug.md` | `/posts/:year/:month/:day/:title/` (date from front matter, title from the file name) |
| `annotations` | `_annotations/<path>.md` | `/annotations/:path/` |
| `books` | `_books/<path>.md` | `/books/:path/` |
| `papers` | `_papers/<group>/index.md` | `/papers/<group>/` (explicit `permalink`) |

Nested topic folders are intentional (`_posts/mathematics/geometry/`). URLs come from the file, not the title:
**renaming or moving a file, or changing a post's `date`, changes its URL** and nothing redirects the old one.
Changing a `title` is safe.

## Front matter

```yaml
---
layout: post
title:  "Course - Topic"
date:   2026-06-28 10:00:00
categories: ["Mathematics"]
tags: ["Pre Calculus"]
description: "One or two sentences for search engines and link previews."
---
```

- `title`, `date` and `categories` (a list) are required; group pages need only `title` and `date`.
- Posts and books need a `description` (validator warning otherwise): without it the first paragraph becomes the meta
  description, which is often a heading, an include or half a sentence. Annotations get a default from `_config.yml`.
- Titles start with a capital; in `Course - Topic` titles the topic does too (`List One`).
- `date` drives the displayed date and the order, and must match the file name. Dates without a zone are read in
  `America/Sao_Paulo`, so local and CI builds agree.
- Categories and tags must exist in `_data/taxonomy.yml`; add a new one there in the same commit.
- Other known keys: `lang`, `permalink`, `files`, `source`, `license_mode`, `license`. Add a new key to `KNOWN_KEYS`
  in `bin/check-content` when you introduce one.

## File names

Lowercase, no spaces (`bin/check-content` fails otherwise; Linux is case-sensitive, macOS is not, and git must track
the same case as the disk: `git mv -f Old new`). New files use `YYYY-MM-DD-slug.md`; the 28 older `YY-MM-DD-` files
are grandfathered in `bin/legacy-short-dates.txt` because renaming them would change their URLs.

## Body

- Sections start at `##` (the title is the page's `h1`) and never skip a level. Use `##`, not underlined `===`/`---`.
- Internal links use `relative_url`; images: `<img src="{{ '/assets/images/<path>' | relative_url }}" alt="...">`,
  with images in `assets/images/{posts,annotations}/` mirroring the content path.
- An image of text (handwritten notes) also gets a transcription:
  `<details markdown="1"><summary>Transcription of the handwritten notes</summary> ... </details>`.
- Math: add `{% include mathjax.html %}` to any page with TeX.

## Language

**A document without the "About the language" notice is in English** (the default; no `lang:`). A pt-BR document has
both:

```yaml
lang: pt-BR
```

```liquid
{% include warning.html title="About the language" text="This document is in pt-br, there's no translation to english." %}
```

Screen readers pick the voice from `lang`; the validator warns when the notice is there without it. Group pages show
the notice by themselves when `lang` is not `en`.

## PDF annotations

Put the PDF in `assets/pdfs/<same-topic>/` and embed it:

```liquid
{% include pdf-viewer.html file="/assets/pdfs/cdi_one/functions_introduction.pdf" height="800px" %}
```

Nothing links the `.md` and its PDF except this path, and their names do not always match: when renaming or moving
one, update the other and the include.

## Paper groups

1. Create `_papers/<slug>/index.md` (never `principal`):

   ```yaml
   ---
   layout: group
   title: "Group title"
   date: 2026-10-08 00:00:00
   lang: pt-BR
   permalink: /papers/<slug>/
   description: "Intro text shown above the list."
   files:
     - divider: "Apresentação"
     - file: "slides.pdf"
       title: "Slides"
     - "material-de-apoio.pdf"
   ---
   ```

2. Put the PDFs next to `index.md`. Only declared files are listed, in that order (the validator warns about
   undeclared ones). `layout: group` works for any folder-of-documents page, not only papers.

## Licensing

Code is MIT (`LICENSE`). Text is CC BY 4.0, but the blog is mostly study notes on other people's material, so by
default every page's footer licenses only the author's own notes. Front matter changes the notice (first match wins;
also settable per folder with a path-scoped `defaults:` entry):

| Field | Footer |
| --- | --- |
| `license: "text"` | Replaces the notice (Markdown allowed). |
| `source: "Prof. X, Course"` | Names the original material and says it is not covered. |
| `license_mode: own` | The whole page is under CC BY 4.0. |
| none | Own notes under CC BY 4.0; third-party material is not. |

`ruby bin/check-content --sources` lists documents without a `source`. Readers' details are at `/license/`
(`pages/license/index.md`); `LICENSE-CONTENT.md` is the repository copy. To change the license, edit the two
`content_license_*` keys in `_config.yml`, both of those files and `_includes/footer.html`.

## Validator: `bin/check-content`

Runs in about a second, in CI before the build and in the hooks.

| Level | Checks |
| --- | --- |
| **Error** (fails CI) | Missing or invalid front matter; missing `title`/`date`/`categories`; unparsable date; an `/assets/...` path or declared group file that does not exist; category or tag outside the taxonomy; upper-case or spaced names; git tracking a different case; a `pages/` file without `permalink`; a page URL colliding with a root file (case-insensitive). |
| **Warning** | Unknown front-matter key; `categories` not a list; date differs from the file name; spelling variants of a category/tag; unreferenced asset; math without `mathjax.html` (or the reverse); `<img>` without `alt`; undeclared PDF in a group folder; lower-case title or topic; new 2-digit-year file; level-1 or underlined heading in the body; skipped heading level; post or book without `description`; pt-BR notice without `lang`. |

## Taxonomy pages and feeds

`pages/{posts,annotations,books}/` each have `tags.html` and `categories.html`. `site.tags`/`site.categories` only
contain posts, so the annotations and books pages build their lists from their own collection; keep that split.
`jekyll-feed` publishes `/feed.xml` (posts) plus `/annotations/feed.xml`, `/books/feed.xml` and `/papers/feed.xml`.

## Deferred (needs the owner's decision)

Compressing the PDFs (245 MB), converting annotation JPEGs to WebP, full-text search (Pagefind), trimming
`Gemfile.lock` platforms, naming real `source:` authors per course, OCR for scanned PDFs.
