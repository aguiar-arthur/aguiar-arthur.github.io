# CLAUDE.md

Guidance for Claude Code when working in this repository. See also `AGENTS.md`
(the human-oriented repository guide); keep both consistent when conventions change.

Detailed documentation lives in `docs/` (components, layouts, papers, assets, content conventions): start at
`docs/README.md`. Keep it in sync when you change an include, a layout or a convention.

## What this is

Arthur Aguiar's personal blog: a static **Jekyll 4.4** site using the theme gem
**`no-style-please`** (the theme is light-only; dark mode comes from `assets/css/site.css` and follows the visitor's system), deployed to GitHub Pages at
`https://aguiar-arthur.github.io`. The site is about programming, mathematics, computer
science and philosophy. Content is English, except some annotations written in pt-BR.

## Commands

```sh
bundle install                 # Ruby 3.4.1 (see .ruby-version)
bundle exec jekyll serve       # dev server at http://127.0.0.1:4000
bundle exec jekyll build       # output to _site/ (what CI runs)
ruby bin/check-content         # content validator (also runs in CI)
ruby bin/check-site            # html-proofer on the built _site/ (needs `gem install html-proofer`; runs in CI)
```

**Always run Jekyll from the repository root.** Running it inside a subfolder (for example `_papers/monads/`)
builds an isolated, unstyled mini-site ("Configuration file: none", "Layout 'group' does not exist") and leaves a
stray `_site/` there.

- `_config.yml` is NOT hot-reloaded: restart `jekyll serve` after editing it.
- `ruby bin/check-content` validates front matter, asset references and taxonomy. Run it after adding or
  editing content; errors fail CI, warnings are advisory. There is no other test suite: **a successful `bundle exec jekyll build` is the build check.**
  Also open the affected page in `jekyll serve` for visual changes (math, PDFs, pagination).
- `_site/`, `.jekyll-cache/`, `.sass-cache/`, `vendor/` are git-ignored build output. Never edit `_site/`.

## Deployment

`.github/workflows/jekyll.yml`: build on every push/PR to `main`; deploy to GitHub Pages
only on push to `main`. Pushing to `main` publishes the site, so avoid pushing broken
builds. The build job runs `ruby bin/check-content` first, builds with `JEKYLL_ENV=production`, then runs `ruby bin/check-site`
(html-proofer, internal links/images/scripts; a failure blocks the deploy). `.github/workflows/links.yml` checks external
links weekly and never blocks; Dependabot
(`.github/dependabot.yml`) proposes gem and action updates weekly. `bin/` must stay versioned (CI needs it); it is
only excluded from the *published site*. Gems `csv` and `logger` in the Gemfile exist for Ruby 3.4+ compatibility; don't remove them.

## Repository map

| Path | Purpose |
| --- | --- |
| `_posts/<topic>/` | Long-form posts. Nested topic dirs are intentional (`mathematics/geometry/`, `computer-science/assembly/`). |
| `_annotations/<course>/` | Study notes, exercise lists, PDF- or image-backed material (custom collection). |
| `_books/<topic>/` | Book notes/reviews (custom collection). |
| `_papers/<group>/` | Two-level collection: each folder is a *group* (`index.md`, `layout: group`) plus its PDFs. |
| `pages/{posts,annotations,books,papers}/` | Standalone pages: `principal.html` (searchable index), `tags.html`, `categories.html`. Every file under `pages/` **must declare a `permalink`** (URLs are independent of the folder). |
| `pages/about/index.html` | The About page. |
| `_layouts/` | `default`, `post`, `home`, `group`: all local (they replace the theme's). `group` is the reusable "folder of documents" page. |
| `_includes/` | `head.html` (overrides theme head), `content-index.html`, `list.html`, `pdf-viewer.html`, `warning.html`, `mathjax.html`, `file-list.html`. |
| `assets/css/{main.scss,site.css,rouge.css}` | `main.scss` imports the theme Sass with `@use`; `site.css` holds site styles and dark mode; `rouge.css` is syntax highlighting. All loaded from `head.html`. |
| `assets/js/content-index.js` | Vanilla-JS client-side search + 10-per-page pagination for the three index pages. |
| `assets/pdfs/<topic>/` | PDFs shown by annotations. Committed as plain binaries (`.gitattributes`: `*.pdf binary`), not Git LFS. |
| `assets/images/{posts,annotations}/...` | Images, mirroring content topic paths. |
| `docs/` | Project documentation (excluded from the site via `exclude:` in `_config.yml`). |
| `bin/check-content`, `bin/check-site` | Content validator (front matter, references, taxonomy, file-name case) and html-proofer wrapper for the built site. |
| `.githooks/`, `.claude/settings.json` | Git pre-commit/pre-push hooks and the Claude Code PostToolUse hook that run the checks. |
| `_data/social_links.yml`, `_data/taxonomy.yml` | About-page links; the allowed categories and tags (validator vocabulary). |
| `404.html`, `index.markdown` | Root pages (`index.markdown` uses `layout: home`; `404.html` must stay at the root). |

## Collections and URLs (`_config.yml`)

| Collection | Source | URL |
| --- | --- | --- |
| `posts` | `_posts/<topic>/YYYY-MM-DD-slug.md` | `/posts/:year/:month/:day/:title/` (date from front matter, `:title` = file-name slug) |
| `annotations` | `_annotations/<path>.md` | `/annotations/:path/` |
| `books` | `_books/<path>.md` | `/books/:path/` |
| `papers` | `_papers/<group>/index.md` | `/papers/<group>/` (explicit `permalink` in each group) |

All four default to `layout: post`. URLs come from the file, not from the page title: `:path` in annotation/book URLs
is the **file path**, and a post's URL uses its file-name slug and its front-matter `date`. So renaming or moving a
file, or changing a post's `date`, changes its URL and nothing redirects the old one. Don't rename without being asked.

Feeds: `jekyll-feed` serves `/feed.xml` (posts) plus `/annotations/feed.xml`, `/books/feed.xml`, `/papers/feed.xml`.

## Writing content

Front matter (copy an existing file as a template):

```yaml
---
layout: post
title:  "Quoted title"
date:   2026-06-28 10:00:00
categories: ["Mathematics"]
tags: ["Pre Calculus"]
---
```

- `title`, `date` and `categories` (a list) are required (group pages need only title and date); `bin/check-content`
  enforces this. The front-matter `date` controls displayed date and sort order and must match the date in the
  file name (the validator warns otherwise). Annotation filenames use either `YY-MM-DD-slug.md` (older) or
  `YYYY-MM-DD-slug.md` (newer); prefer the full year. Collection pages show the date under the title.
- File and folder names are lowercase without spaces (`bin/check-content` fails otherwise); the front-matter `title` carries the capitalisation: titles start with a capital, and in `Course - Topic` titles the topic does too (`List One`, not `list one`); the validator warns otherwise.
- **Fixed vocabulary:** categories and tags must be listed in `_data/taxonomy.yml`; anything else is a validator error. Add the new entry in the same commit as the document that needs it.
- New files use a 4-digit year in the name (`2026-03-22-slug.md`); the validator warns on `YY-` names. The 28 existing short-year files are grandfathered in `bin/legacy-short-dates.txt` (renaming changes their URLs); don't add to that list.
- Categories are capitalised, in a list (`["Mathematics"]`). Reuse existing categories/tags
  (e.g. Mathematics, Computer Science, Programming, Design; tags like "Linear Algebra", "CDI one",
  "Pre Calculus") rather than inventing near-duplicates; the validator warns about spelling variants
  (`Mathematics` vs `mathematics`).
- Markdown is Kramdown (GFM input) with Rouge highlighting.
- **Licensing**: code is MIT; text and notes are CC BY 4.0 (footer on every page, `/license/`). The whole site defaults to a "based on third-party material;
  only the author's own contribution is licensed" footer (the blog is study notes and reviews). Name the real author
  with `source: "Prof. X, Course"` (per page, or per folder via path-scoped `defaults:`), use `license_mode: own` only for a
  page that is entirely the author's, or `license: "..."` to replace the notice. `ruby bin/check-content --sources` lists
  documents without a `source`. Don't remove
  or change the license wording without being asked.
- **Math**: add `{% include mathjax.html %}` to any page using TeX (`$$...$$`). It loads MathJax 4
  from jsDelivr; without the include, math renders as raw text.
- **PDF annotations**: put the PDF in `assets/pdfs/<same-topic>/` and embed it:
  `{% include pdf-viewer.html file="/assets/pdfs/<topic>/<name>.pdf" height="800px" %}`.
  No automatic link between the `.md` and its PDF exists; when renaming or moving one, update the other
  and the include path. (PDF filenames don't always match the annotation slug — check before assuming.)
- **pt-BR documents**: in posts/annotations/books add `{% include warning.html title="About the language" text="This document is in pt-br, there's no translation to english." %}`; `layout: group` pages show it automatically when `lang` is not `en`.
- **Images**: `<img src="{{ '/assets/images/<...>' | relative_url }}" alt="...">`.
- Internal links in templates and content must use the `relative_url` filter.
- A new category/tag appears on the taxonomy pages automatically; no registration step.

## Papers (grouped documents)

`pages/papers/principal.html` lists the groups (`site.papers | where: "layout", "group"`) through the
shared searchable index. Opening a group shows a second-level page: language banner, `description`
as intro text, then the list of documents. To add a group:

1. Create `_papers/<slug>/index.md` with `layout: group`, `title`, `date`, `permalink: /papers/<slug>/`,
   `description`, and `lang: pt-BR` (any `lang` other than `en` shows the "no english translation" banner).
2. Put the PDFs next to it in `_papers/<slug>/` and declare each one in `index.md`:
   `files: [{ file: "x.pdf", title: "Título" }]`. **Only declared files are listed**, in that order
   (a PDF in the folder but not in `files:` is not shown). Plain strings work too; names starting with
   `/` are used as-is (e.g. `/assets/pdfs/...`). `- divider: "Any text"` entries add a section heading between
   documents (splitting the list in blocks).

`_layouts/group.html` + `_includes/file-list.html` are collection-agnostic: reuse them for any
folder-of-documents page (e.g. `_books/<x>/index.md` with `layout: group`). Don't name a group
`principal` (clashes with the index page). PDFs in `_papers/` are Jekyll static files, copied to
`/papers/<slug>/<file>.pdf`; they are committed like all PDFs (plain binaries).

## Gotchas

- Index pages are rendered fully server-side; `content-index.js` hides items client-side. Search
  matches title, date, category and tag text (built in `_includes/content-index.html`).
- `site.tags`/`site.categories` only contain posts, so `pages/posts/{tags,categories}.html` use them directly while the
  annotations/books taxonomy pages iterate their own collections. Keep that split if you touch them.
- `_layouts/home.html` builds "Latest Posts" (5) and "Latest Annotations" (3) from `site.posts` and
  `site.annotations`; books and papers are not on the home page.
- Page URLs must not collide, ignoring case, with root files copied to `_site/` (macOS is case-insensitive); that is why
  `LICENSE` is in `exclude:` next to `/license/`. The validator checks it.
- File and folder names in content directories must be lowercase without spaces, and the git index must match the disk's case (macOS hides case-only renames from git; fix with `git mv -f Old new`). `bin/check-content` enforces both as errors through the pre-commit and Claude hooks.
- `head.html` overrides the theme's head (favicon from `site.favicon`, then `main.css`, `rouge.css`,
  `site.css`). Edit carefully; the theme's own `head` is not inherited.
- The theme (`no-style-please` 0.1.0) is tiny and light-only. Light/dark comes from CSS variables and
  `prefers-color-scheme` in `assets/css/site.css`; use the `--site-*` variables, never hardcoded colours.
- PDFs are plain binary blobs (`.gitattributes`: `*.pdf binary`); no Git LFS pointers exist in the history. If a
  local `.git/config` or an old `.gitattributes` still applies `filter=lfs`, `git status` lists every PDF as modified;
  that is a tooling mismatch, not a content change. Do not stage those files.
- Gems are installed wherever the developer chooses (`.bundle/` and `/vendor/` are git-ignored); never commit them.
- Styling should stay minimal and theme-compatible; put overrides in `assets/css/site.css` using the
  existing `--site-*` custom properties. Avoid adding JS frameworks or build tooling (the site is
  deliberately dependency-light).
- `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/` and `bin/` are in `exclude:` and are not published.

## Working conventions

- Prefer small, content-focused commits; the history uses short imperative messages
  (`feat: ...`, `docs: ...` or plain lowercase).
- Don't commit `_site/` or generated caches.
- After adding or editing content run `ruby bin/check-content`, then verify with `bundle exec jekyll build` that it
  renders and its URL resolves.
- Hooks run the validator automatically: a Claude Code `PostToolUse` hook (`.claude/settings.json`, after every
  edit/write) and a Git pre-commit hook (`.githooks/pre-commit`, enabled per clone with
  `git config core.hooksPath .githooks`). A pre-push hook (`.githooks/pre-push`) builds into `tmp/site` and runs
  `bin/check-site`; it is kept out of the edit and commit hooks because it needs a build. If a hook reports errors, fix them before continuing.
- Keep `docs/`, this file and `AGENTS.md` in sync with any change to includes, layouts, conventions or tooling.
- Deferred on purpose (need the owner's decision, see `docs/content.md`): compressing the 245 MB of PDFs, converting
  annotation JPEGs to WebP, full-text search (Pagefind), trimming `Gemfile.lock` platforms, naming real `source:` authors per course.
