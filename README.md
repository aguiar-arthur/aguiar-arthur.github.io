# aguiar-arthur.github.io

Arthur Aguiar's personal blog: posts, study annotations, book notes and papers about programming,
mathematics, computer science and philosophy. Built with [Jekyll](https://jekyllrb.com) and published to
GitHub Pages at <https://aguiar-arthur.github.io>.

## Run locally

Requires Ruby (see `.ruby-version`) and Bundler.

```sh
bundle install
bundle exec jekyll serve      # http://127.0.0.1:4000  (run from the repository root)
ruby bin/check-content        # validates front matter, references and taxonomy
```

PDFs are stored with Git LFS (`git lfs install` before cloning or pulling).

## Where things are

| Path | Content |
| --- | --- |
| `_posts/`, `_annotations/`, `_books/`, `_papers/` | The content collections. |
| `_includes/`, `_layouts/`, `assets/` | Components, layouts, styles and script. |
| `docs/` | Documentation: components, layouts, papers, assets, content conventions. |
| `AGENTS.md`, `CLAUDE.md` | Repository guides for coding agents. |

Every push to `main` is validated and deployed by `.github/workflows/jekyll.yml`.
