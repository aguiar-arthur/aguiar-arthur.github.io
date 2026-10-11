# How the site is built

Templates, components, styles and accessibility conventions. For writing content see [content.md](content.md); for
tooling, CI and tests see [maintenance.md](maintenance.md).

```text
Markdown content (_posts, _annotations, _books, _papers)
  └─ front matter picks a layout (post by default, group for paper groups)
       └─ layout composes includes (warning, pdf-viewer, file-list, content-index, ...)
            └─ theme no-style-please supplies the base Sass; assets/css/site.css customises on top
```

## Layouts (`_layouts/`)

All four are local; `default` and `post` replace the theme's, so the site does not depend on the theme's markup.

| Layout | Used by | What it renders |
| --- | --- | --- |
| `default` | everything (directly: `404.html`) | `<html lang>` (`page.lang`, then `site.lang`), `head.html`, the only `<main>` landmark with the theme's `.wrapper`, then `footer.html`. |
| `post` | collection documents (via `defaults:`), `pages/` | "← Home" link, the `<h1>` title and, for collection documents except groups, the date (`<time>`). |
| `home` | `index.markdown` | Skip link, site title, main navigation, the 5 latest posts, 3 latest annotations and 3 latest paper groups (via `list.html`, each with an empty-state message). Books are not on the home page. |
| `group` | `_papers/<slug>/index.md` (any collection works) | Language notice when `lang` is not `en`, `description` as intro, the Markdown body, then `file-list.html` with the declared `files`. |

Chains: `group` → `post` → `default`; `home` → `default`. The back link, the date and the footer are English site
chrome and carry `lang="{{ site.lang }}"` so they are read correctly on pt-BR pages.

## Includes (`_includes/`)

Call them with `{% include name.html key="value" %}`; inside, parameters are `include.key` (missing ones are `nil`).
All but `mathjax` and `head` have unit tests ([maintenance.md](maintenance.md#tests)); update the test with the include.

| Include | Parameters | Notes |
| --- | --- | --- |
| `mathjax.html` | none | Loads MathJax 4 from jsDelivr. Display math `$$...$$` or `\[...\]`, inline `\(...\)`; single `$` is not a delimiter. Without it, TeX shows as raw text. |
| `pdf-viewer.html` | `file` (required, `/assets/pdfs/...`), `height` (`800px`), `title` (page title) | "Open PDF" link (new tab) above an `<object>` with a fallback link. `title` names the object and the links for screen readers. |
| `warning.html` | `text` (required, Markdown, no double quotes), `title`, `lang` (`site.lang`) | Bordered notice with `role="note"`; the title is bold text, not a heading. |
| `list.html` | `items` (`title`, optional `url`), `class`, `item_class` | `<ul class="list">`. URLs starting with `/` go through `relative_url`; others are kept. Renders nothing when empty. |
| `content-index.html` | `items` (sorted by you), `id` (required, unique), `empty_message` | Searchable index used by the four `principal.html` pages; loads `assets/js/content-index.js`. |
| `file-list.html` | `files`, `base` (`/`), `ext` (`.pdf`) | Only declared entries, in order. Relative names resolve against `base`; names starting with `/` are used as is. `{ divider: "Text" }` adds an `<h2>` and splits the list. Without a `title`, the label comes from the file name. Links open in a new tab and say so. |
| `head.html` | none | Replaces the theme's head: meta, `{% feed_meta %}`, `{% seo %}`, optional GoatCounter (production only), favicon, then `main.css`, `rouge.css`, `site.css` (last wins). |
| `footer.html` | none (reads the page's licensing front matter) | Copyright and the license notice; see [content.md](content.md#licensing). |

**Search** (`content-index.html` + `content-index.js`): every item is rendered server side with a `data-search`
attribute (lowercase title, date, categories and tags); the script filters by substring, shows 10 per page, toggles
the "no results" message and the Previous/Next buttons, announces results in a polite live region and moves focus to
the list after a page change. The script depends on the `data-index-*` attributes of the include: rename both together.
It has no unit tests; check it by hand in `jekyll serve` after changing either file.

## Styles (`assets/css/`)

| File | Role |
| --- | --- |
| `main.scss` → `main.css` | `@use "no-style-please"`: the theme's base (monospace, 640px column). |
| `rouge.css` | Syntax highlighting (dark in both themes). |
| `site.css` | Everything this site adds, loaded last. |

- **Colours** are CSS variables (`--site-color`, `--site-background`, `--site-link`, `--site-focus`, borders and
  `--site-space-1..5`), redefined under `prefers-color-scheme: dark`. The theme is light-only: never hardcode colours.
- **Layout**: the theme's `.wrapper` uses `width: fit-content`, which let one wide image, table or code block push the
  column past a phone's screen. `site.css` sets `width: auto` (the 640px max stays), `overflow-wrap: break-word`,
  `img { max-width: 100% }`, scrollable tables and scrollable display equations. Check new wide content at 375px.
- **Focus**: links, buttons, inputs and `[tabindex]` share one `:focus-visible` outline; the search box shows it on
  any focus. Never remove an outline without a replacement.
- Prefer a class on the component over restyling bare elements; `.visually-hidden` hides text visually but keeps it
  for screen readers.

## Paper groups

`/papers/principal/` lists the groups (`site.papers | where: "layout", "group"`, newest first); each group page
shows its intro and documents. PDFs stored next to `index.md` are copied by Jekyll to `/papers/<slug>/<file>.pdf`.
How to add one: [content.md](content.md#paper-groups).

## Accessibility

- **Language**: `<html lang>` follows the page's `lang`. English chrome inside pt-BR pages is marked
  `lang="{{ site.lang }}"` (back link, date, footer, notices, PDF links, "(opens in a new tab)").
- **Headings**: the title is the only `<h1>`; body sections start at `##` and do not skip levels (the validator warns).
- **Keyboard**: shared focus outline, skip link on the home page, focus moves to the results after a page change.
- **Screen readers**: links that open a new tab say so, the PDF viewer is named after the page, search results are
  announced, static notices use `role="note"` (never `alert`).
- **Images**: every `<img>` needs `alt`; images of text (handwritten notes) also need a transcription below them.
- **Colour**: text and links meet WCAG AA in both themes (8:1 light, 9:1 dark); Rouge token colours are at least
  5.6:1. Links in the text colour (`.pdf-viewer`) keep their underline.
- Scanned PDFs have no text layer; OCR is a deferred decision.

For a manual check, run `bundle exec jekyll serve` and use axe DevTools or Lighthouse on a post, a pt-BR annotation,
an index page and a group page.
