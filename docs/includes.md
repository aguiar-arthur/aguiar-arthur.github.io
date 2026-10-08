# Includes (`_includes/`)

Seven components. Call them with `{% include <file> key="value" %}`; read parameters with
`include.key` inside the file. Unknown or missing parameters are `nil` (Jekyll does not fail).

| Include | Used in | Purpose |
| --- | --- | --- |
| [`mathjax.html`](#mathjaxhtml) | posts/annotations with math | Loads MathJax so `$$...$$` renders. |
| [`pdf-viewer.html`](#pdf-viewerhtml) | annotations | Embeds a PDF with an "Open PDF" link. |
| [`warning.html`](#warninghtml) | annotations, `group` layout | Highlighted notice box. |
| [`list.html`](#listhtml) | `home` layout, About page | Plain link list from `{title, url}` items. |
| [`content-index.html`](#content-indexhtml) | the three `principal.html` index pages (+ papers) | Searchable, paginated index of documents. |
| [`file-list.html`](#file-listhtml) | `group` layout | Links to files declared in a group's front matter. |
| [`head.html`](#headhtml) | every page (theme) | Overrides the theme's `<head>`. |

---

## `mathjax.html`

Renders TeX math in the browser with MathJax 4.

**Use** (once, near the top of the page body, after the front matter):

```liquid
{% include mathjax.html %}

Display: $$ \int_0^1 x^2\,dx = \tfrac{1}{3} $$
Inline: \( a^2 + b^2 = c^2 \)
```

**How it works**
- Sets `window.MathJax` options (`chtml.linebreaks.automatic: true`, `width: "container"`) so long
  formulas wrap to the container width, then loads `tex-mml-chtml.js` from jsDelivr with `defer`.
- Pages without the include do not load MathJax: math shows as raw text.

**Caveats**
- MathJax's defaults apply: display math is `$$...$$` or `\[...\]`; inline math is `\(...\)`.
  Single-dollar `$...$` is **not** an inline delimiter.
- Needs network access to `cdn.jsdelivr.net` at view time.
- `assets/css/site.css` makes display equations horizontally scrollable on narrow screens.

---

## `pdf-viewer.html`

Embeds a PDF (browser's built-in viewer) with an "Open PDF" link above it and a fallback message.

| Parameter | Required | Default | Meaning |
| --- | --- | --- | --- |
| `file` | yes | - | Site-root path starting with `/assets/pdfs/`. Passed through `relative_url`. |
| `height` | no | `800px` | CSS height of the embedded viewer. |
| `title` | no | `PDF document` | `aria-label` of the embedded object. |

```liquid
{% include pdf-viewer.html file="/assets/pdfs/cdi_one/functions_introduction.pdf" %}
{% include pdf-viewer.html file="/assets/pdfs/linear_algebra/list_one.pdf" height="1000px" title="Linear algebra, list 1" %}
```

**How it works**: renders `<div class="pdf-viewer">` with a card (`.pdf-viewer__open-card`) linking
to the PDF (`target="_blank" rel="noopener noreferrer"`) and an `<object type="application/pdf">`
whose inner `<p>` is the fallback for browsers that cannot display PDFs (typically mobile).

**Caveats**
- There is no link between the annotation's `.md` file and its PDF other than this path. When you
  rename or move either, update the include. Mirror the topic folder (`_annotations/<topic>/` ↔
  `assets/pdfs/<topic>/`).
- PDFs are Git LFS files (`.gitattributes`); see `../CLAUDE.md` if `git status` looks wrong.

---

## `warning.html`

A highlighted notice (`<div class="notice notice--warning" role="alert">`).

| Parameter | Required | Meaning |
| --- | --- | --- |
| `title` | no | Heading (`<h6 class="notice__title">`). Omitted when empty. |
| `text` | yes | Body. Rendered as Markdown (`markdownify`); the wrapping `<p>` tags are removed. |

```liquid
{% include warning.html
   title="About the language"
   text="This document is in pt-br, there's no translation to english." %}
```

**Caveats**: the `text` string cannot contain double quotes (use single quotes or Markdown
emphasis). For pt-BR content prefer the `group` layout, which adds this notice by itself when
`lang` is not `en`; in annotations and posts, paste the snippet above.

---

## `list.html`

A simple `<ul>` of links.

| Parameter | Required | Default | Meaning |
| --- | --- | --- | --- |
| `items` | yes | - | Array of objects with `title` and (optional) `url`. Documents, or data like `site.data.social_links`. |
| `class` | no | `list` | Extra class on the `<ul>` (it is always `list` plus this value). |
| `item_class` | no | empty | Extra class on each `<li>` (always `list__item` plus this value). |

```liquid
{% include list.html items=site.data.social_links %}
{% assign latest = site.posts | slice: 0, 5 %}
{% include list.html items=latest %}
```

**How it works**: renders nothing when `items` is empty. An item without `url` is shown as plain text.

**How URLs are handled**: an `url` starting with `/` (a document or page of this site) goes through
`relative_url`, so it respects `baseurl`; any other value (`https://...`, `mailto:...`) is output unchanged.

---

## `content-index.html`

The searchable, paginated index used by `posts/principal.html`, `annotations/principal.html`,
`books/principal.html` and `papers/principal.html`.

| Parameter | Required | Default | Meaning |
| --- | --- | --- | --- |
| `items` | yes | - | Documents to list (already sorted by you). Each needs `title`, `date`, `url`; `categories`/`tags` improve search. |
| `id` | yes | - | Unique id on the page; used for the search input's `id` and its label. |
| `empty_message` | no | `No items available yet.` | Text shown when `items` is empty. |

```liquid
{% assign books = site.books | sort: "date" | reverse %}
{% include content-index.html items=books id="books" empty_message="No books available yet." %}
```

**How it works**
1. Server side (Liquid): every item becomes `<li data-index-item data-search="...">` containing the
   link and the date. `data-search` holds the lowercase, escaped text of title, date
   (`%B %d, %Y`), categories and tags.
2. Client side (`assets/js/content-index.js`): on `DOMContentLoaded` it finds every `[data-per-page]`
   container, filters items by the search box (substring match on `data-search`), shows 10 per page
   (`data-per-page="10"` is hardcoded in the include), and toggles the "no results" message and the
   Previous/Next navigation.
3. The include loads the script itself (`defer`), so pages need nothing else. The script marks each index
   it initialises (`data-index-ready`), so a second load or a second instance never wires an index twice.

**Caveats**
- Several indexes on one page are supported: give each a different `id`.
- Sorting and filtering of the item list happens before the include; the include does not sort.
- Because everything is rendered into the HTML and hidden by JS, very large collections make the page heavier.

---

## `file-list.html`

Lists the documents a group page declares. Used by `_layouts/group.html`; see [papers.md](papers.md).

| Parameter | Required | Default | Meaning |
| --- | --- | --- | --- |
| `files` | yes | - | Entries: a string (`"a.pdf"`) or an object (`{ file: "a.pdf", title: "Title" }`). |
| `base` | no | `/` | URL of the group page, used to resolve relative file names. |
| `ext` | no | `.pdf` | Extension removed when a title is derived from the file name. |

```liquid
{% include file-list.html files=page.files base=page.url %}
```

**How it works**
- Only declared files are listed, in declared order. Nothing is discovered on disk.
- Relative names are resolved against `base` (`/papers/monads/` + `slides.pdf`); names starting with
  `/` are used as-is (for example `/assets/pdfs/x.pdf`). All URLs pass through `relative_url`.
- Without a `title`, the label is the file name without extension, with `-`/`_` turned into spaces and the
  first letter capitalised (`material-de-apoio.pdf` -> `Material de apoio`).
- Links open in a new tab. With no entries it prints `No documents yet.`

---

## `head.html`

Overrides the theme's `<head>`, so changes here affect every page.

Contents: charset/viewport/IE meta, `{% feed_meta %}` (jekyll-feed), `{% seo %}` (jekyll-seo-tag, from the
theme/default plugins), optional GoatCounter (only if `site.goat_counter` is set and the environment is
production), the favicon (`site.favicon`, set to `/favicon.ico` in `_config.yml`) and three stylesheets, in this order:

1. `/assets/css/main.css` - generated by the theme from its Sass.
2. `/assets/css/rouge.css` - syntax highlighting.
3. `/assets/css/site.css` - this site's overrides (loaded last so it wins).

**Caveats**: the theme's own `head` is not inherited; anything the theme normally puts there must be
repeated here. If the theme is not loaded (for example when Jekyll runs from a subfolder without
`_config.yml`), `main.css` is missing and pages look unstyled.
