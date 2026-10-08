# Papers

A two-level section: `/papers/principal/` lists **groups** (for example an article), and opening a
group shows its own page with an introduction and its documents.

```text
_papers/
  monads/
    index.md                 <- the group (layout: group)
    material-de-apoio.pdf    <- documents, listed only if declared in index.md
    slides.pdf
papers/
  principal.html             <- list of groups (uses content-index.html)
```

## Add a new group

1. Create `_papers/<slug>/index.md`:

   ```yaml
   ---
   layout: group
   title: "Group title"
   date: 2026-10-08 00:00:00
   lang: pt-BR            # anything other than "en" shows the no-translation notice
   permalink: /papers/<slug>/
   description: "Intro text shown above the list."
   files:
     - file: "document.pdf"
       title: "Display title"
   ---
   ```

2. Put the PDFs next to `index.md`.
3. Declare each PDF under `files:`. Files in the folder that are not declared are not listed.
4. Optionally group them with dividers, which can hold any text and be placed between any two entries:

   ```yaml
   files:
     - divider: "Apresentação"
     - file: "slides.pdf"
       title: "Slides"
     - divider: "Material de apoio"
     - file: "material-de-apoio.pdf"
   ```

## How it fits together

- `_config.yml` defines the `papers` collection (`output: true`, `permalink: /papers/:path/`). Each
  group sets its own `permalink`, because the default would produce `/papers/<slug>/index/`.
- `pages/papers/principal.html` lists `site.papers | where: "layout", "group"` through `content-index.html`,
  newest `date` first. Plain Markdown documents in `_papers/` (non-group) are not listed.
- PDFs in `_papers/<slug>/` are static files of the collection; Jekyll copies them to
  `/papers/<slug>/<file>.pdf`, which is how `file-list.html` links them.
- `_layouts/group.html` renders the page (see [layouts.md](layouts.md)).

## Gotchas

- Do not name a group `principal`; it would collide with the index page URL.
- The group's `date` is not shown on the page (the theme's `post` layout prints only the title); it is the sort key on the index and appears next to the title in the index list.
- Always run Jekyll from the repository root. Running it inside `_papers/<slug>/` builds an isolated,
  unstyled mini-site and warns that the layout `group` does not exist.
- PDFs are plain binaries in Git (see [repository.md](repository.md)).
