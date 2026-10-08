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
bundle exec jekyll build && ruby bin/check-site   # broken links/images in the built site (gem install html-proofer first)
git config core.hooksPath .githooks   # once per clone: validator on commit, site link check on push
```

Gems install wherever you configure Bundler; to keep them inside the project use
`bundle config set --local path vendor/bundle` (git-ignored).

## Where things are

| Path | Content |
| --- | --- |
| `_posts/`, `_annotations/`, `_books/`, `_papers/` | The content collections. |
| `pages/` | Standalone pages: indexes, tags, categories, About. |
| `_includes/`, `_layouts/`, `assets/` | Components, layouts, styles and script. |
| `docs/` | Documentation: components, layouts, papers, assets, content conventions. |
| `AGENTS.md`, `CLAUDE.md` | Repository guides for coding agents. |

## License

Code: MIT (`LICENSE`). Text, notes and papers: CC BY 4.0 unless a page says otherwise (see
`LICENSE-CONTENT.md` and <https://aguiar-arthur.github.io/license/>).

Every push to `main` is validated and deployed by `.github/workflows/jekyll.yml`.
