# Repository guide

Arthur Aguiar's personal blog: a static **Jekyll 4.4** site on the `no-style-please` theme (light-only; dark mode comes
from `assets/css/site.css` and follows the visitor's system), deployed to GitHub Pages at
`https://aguiar-arthur.github.io`. Posts, study annotations, book notes and papers about programming, mathematics,
computer science and philosophy. Content is English, except annotations marked as pt-BR.

Details live in `docs/`: [content.md](docs/content.md) (writing), [site.md](docs/site.md) (templates, styles,
accessibility), [maintenance.md](docs/maintenance.md) (tooling, CI, hooks, tests). Keep them in sync with any change
to includes, layouts, conventions or tooling.

## Commands

```sh
bundle install                 # Ruby 4.0.7 (.ruby-version)
bundle exec jekyll serve       # http://127.0.0.1:4000 — always from the repository root
bundle exec jekyll build       # output to _site/ (what CI runs)
ruby bin/check-content         # content validator (CI)
bundle exec rake test          # unit tests of _includes/ and bin/check-content (CI)
ruby bin/check-site            # html-proofer on _site/ (gem install html-proofer --version '~> 5.0'; CI)
git config core.hooksPath .githooks   # once per clone
```

- `_config.yml` is not hot-reloaded: restart `jekyll serve` after editing it.
- After editing content run `ruby bin/check-content` (errors fail CI, warnings are advisory); after changing
  `_includes/` or `bin/check-content` run `bundle exec rake test` and update the matching test. A successful
  `bundle exec jekyll build` is the build check; open visual changes (math, PDFs, pagination, mobile width) in
  `jekyll serve`.
- **Pushing to `main` publishes the site** (`.github/workflows/jekyll.yml`: `test` and `build` in parallel, `deploy`
  needs both). Never push a broken build.

## Repository map

| Path | Purpose |
| --- | --- |
| `_posts/<topic>/` | Posts; nested topic folders are intentional. |
| `_annotations/<course>/` | Study notes, exercise lists, PDF- or image-backed material. |
| `_books/<topic>/` | Book notes. |
| `_papers/<group>/` | Groups: `index.md` (`layout: group`) plus its PDFs. |
| `pages/` | Index, tag and category pages, About, License. Every file declares a `permalink`. |
| `_layouts/`, `_includes/` | Local layouts (`default`, `post`, `home`, `group`) and components. |
| `assets/css/` | `main.scss` (theme), `rouge.css`, `site.css` (all site styles; use the `--site-*` variables). |
| `assets/js/content-index.js` | Search and pagination of the index pages. |
| `assets/pdfs/`, `assets/images/` | PDFs (plain binaries, not LFS) and images, mirroring content paths. |
| `_data/` | `taxonomy.yml` (allowed categories and tags), `social_links.yml`. |
| `bin/`, `test/`, `.githooks/` | Validator, html-proofer wrapper, test runner; Minitest suite; Git hooks. Not published. |
| `404.html`, `index.markdown`, `robots.txt` | Root pages. |

## Writing content

```yaml
---
layout: post
title:  "Quoted Title"
date:   2026-06-28 10:00:00
categories: ["Mathematics"]
tags: ["Pre Calculus"]
description: "One or two sentences for search results and link previews."
---
```

- `title`, `date`, `categories` (a list) are required; posts and books also need `description`. `date` must match the
  file name. Categories and tags must be in `_data/taxonomy.yml` (add new ones in the same commit; reuse existing ones).
- File and folder names are lowercase without spaces; new files use `YYYY-MM-DD-slug.md`. **URLs come from the file
  path and `date`, not the title: never rename or move content unless asked** (nothing redirects old URLs).
- Body sections start at `##` and never skip a level (the title is the page's `h1`). Images need `alt`; images of text
  also need a transcription. Internal links use the `relative_url` filter.
- Math: `{% include mathjax.html %}`. PDFs: `assets/pdfs/<topic>/` +
  `{% include pdf-viewer.html file="/assets/pdfs/<topic>/<name>.pdf" height="800px" %}` (names don't always match the
  annotation slug; check before assuming).
- **Language: a document without the "About the language" notice is English.** pt-BR documents set `lang: pt-BR` and
  include `{% include warning.html title="About the language" text="This document is in pt-br, there's no translation to english." %}`.
- Licensing: code MIT, text CC BY 4.0 for the author's own contribution only (the footer says so on every page). Use
  `source:`, `license_mode: own` or `license:` to change the notice; don't change license wording unless asked.
- Paper groups and the full validator rule list: [docs/content.md](docs/content.md).

## Conventions and gotchas

- Keep styling minimal and theme-compatible, in `assets/css/site.css`, with the `--site-*` variables (never hardcoded
  colours). No JS frameworks or build tooling: the site is deliberately dependency-light.
- `_config.yml` must keep `author:`; without it the SEO tags and feeds credit the theme's author.
- `head.html` replaces the theme's head entirely; `site.tags`/`site.categories` contain only posts (the annotations and
  books taxonomy pages iterate their own collections).
- Page URLs must not collide, ignoring case, with root files copied to `_site/` (`LICENSE` is excluded for `/license/`).
- Never edit or commit `_site/`, caches or `vendor/`. If `git status` lists every PDF as modified, a local LFS filter
  is mismatched: don't stage them.
- Commits: small, short imperative messages (`feat: ...`, `docs: ...` or plain lowercase).
- Deferred on purpose (owner's decision): compressing the PDFs, WebP images, full-text search, trimming
  `Gemfile.lock` platforms, naming `source:` authors per course.
