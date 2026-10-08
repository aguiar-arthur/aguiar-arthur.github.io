# Blog documentation

Technical documentation for the Jekyll blog at `https://aguiar-arthur.github.io`.
It is excluded from the published site (`exclude: docs/` in `_config.yml`).

| Document | What it covers |
| --- | --- |
| [includes.md](includes.md) | Every reusable component in `_includes/`: parameters, usage, how it works, caveats. |
| [layouts.md](layouts.md) | The custom layouts (`home`, `group`) and how they relate to the theme's layouts. |
| [papers.md](papers.md) | The `papers` collection: grouped documents, how to add a new group. |
| [assets.md](assets.md) | CSS (light/dark palette, classes), the client-side search/pagination script, and where PDFs and images live. |
| [content.md](content.md) | Front matter and naming conventions, the `bin/check-content` validator, taxonomy pages, feeds, deferred work. |

Quick references live in `../CLAUDE.md` (for Claude Code) and `../AGENTS.md` (repository guide).

## Mental model

```text
Markdown content (_posts, _annotations, _books, _papers)
  └─ front matter picks a layout (post by default, group for paper groups)
       └─ layout composes includes (warning, pdf-viewer, file-list, content-index, ...)
            └─ theme `no-style-please` supplies default/post layouts and base CSS
                 └─ assets/css/site.css + rouge.css customise on top
```

- **Includes** are Liquid snippets called from content or layouts:
  `{% include name.html param="value" %}`. Inside the snippet, parameters are read as `include.param`.
- Authors normally only need `warning`, `pdf-viewer` and `mathjax` inside Markdown. The others
  are used by layouts and index pages.
- There is no build tooling besides Jekyll: no tests, no linters. `bundle exec jekyll build` succeeding
  (and the page looking right in `jekyll serve`) is the check.
