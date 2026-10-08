# Assets

## Stylesheets (`assets/css/`)

| File | Role |
| --- | --- |
| `main.scss` -> `main.css` (generated) | Entry point of the theme styles (monospace body, 640px wrapper). `main.scss` is local and does `@use "no-style-please"` (the theme's partial); the theme's own copy used the deprecated `@import`. |
| `rouge.css` | Syntax highlighting for fenced code blocks (Rouge). |
| `site.css` | This site's overrides, loaded last (`head.html`). |

`site.css` is organised around CSS custom properties (`--site-color`, `--site-background`, `--site-link`,
`--site-focus`, `--site-border`, `--site-space-1..5`) and component classes.

**Light/dark**: the palette is defined in `:root` (light) and redefined inside
`@media (prefers-color-scheme: dark)`; `color-scheme: light dark` lets form controls follow. The site follows the
visitor's system setting; there is no manual toggle. The theme itself has no dark mode, so never hardcode
colours in components: use the variables. (The old `theme_config.appearance` setting did nothing and was removed.)

| Class | Component |
| --- | --- |
| `.home-page`, `.skip-link` | Landing page and its accessibility skip link. |
| `.pdf-viewer`, `.pdf-viewer__open-card` | `pdf-viewer.html`. |
| `.content-index__*` (`search`, `search-label`, `list`, `no-results`, `pagination`) | `content-index.html`. |
| `.list`, `.list__item` | `list.html` and `file-list.html`. |
| `.file-list-group`, `.file-list__divider` | `file-list.html` wrapper and its divider headings. |
| `.taxonomy-list` | `tags.html` / `categories.html` pages. |
| `.notice__title`, `.notice__content` | `warning.html`. |
| `.about-card` | About page. |
| `.back-home`, `.post-meta` | Back link and date line of `post.html`. |

Guidelines: keep overrides minimal and theme-compatible, reuse the custom properties, and prefer a
class on the component over restyling bare elements. `mjx-container[display="true"]` is made scrollable
so wide equations do not break the layout on mobile.

## Script (`assets/js/content-index.js`)

Vanilla JS, no dependencies. For every `[data-per-page]` element it wires up search, pagination
(10 per page unless `data-per-page` says otherwise) and the empty state. It relies on the data attributes
emitted by `content-index.html` (`data-index-list`, `-search`, `-item`, `-pagination`, `-previous`,
`-next`, `-status`, `-no-results`) and sets `data-index-ready` on each index once initialised, so it is safe
if the script loads twice; renaming one requires changing both files.

## Files

| Path | Content |
| --- | --- |
| `assets/pdfs/<topic>/` | PDFs shown by annotations through `pdf-viewer.html`. plain binaries (not LFS). |
| `_papers/<slug>/` | PDFs of paper groups (kept next to their `index.md`). plain binaries (not LFS). |
| `assets/images/posts/...`, `assets/images/annotations/...` | Images, mirroring the content topic path. |

Reference images with `<img src="{{ '/assets/images/<path>' | relative_url }}" alt="...">`.
Provide meaningful `alt` text.
