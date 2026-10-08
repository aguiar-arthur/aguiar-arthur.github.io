# Repository layout and hygiene

## Layout

```text
_posts/ _annotations/ _books/ _papers/   content collections
pages/                                    standalone pages (indexes, tags, categories, About); each declares its permalink
_layouts/ _includes/                      templates and components
assets/{css,js,pdfs,images}/              static files
_data/                                    YAML data used by templates
docs/ bin/                                documentation and tooling (not published)
404.html index.markdown                   root pages
.github/                                  CI workflow and Dependabot
```

Only files that must be at the root are at the root. Pages that used to live in top-level `posts/`, `annotations/`,
`books/`, `papers/` and `about/` now live under `pages/`; their URLs did not change because each page sets an explicit
`permalink` (`bin/check-content` enforces that).

## What is versioned and what is not

Ignored (`.gitignore`): `_site/`, `.jekyll-cache/`, `.jekyll-metadata`, `.sass-cache/`, `.bundle/`, `/vendor/`,
`.rumdl_cache/`, `.DS_Store`.

- **Gems are not vendored.** `.bundle/config` used to be committed with `BUNDLE_PATH: "vendor/bundle"`, which forced a
  machine-specific install path on everyone. It is now untracked. Install location is a local choice:
  `bundle config set --local path vendor/bundle` keeps gems inside the project (ignored by Git); omitting it uses the
  system gem directory. CI installs its own gems (`bundler-cache: true`).
- **Case-insensitive filesystems (macOS).** Root files that Jekyll copies to `_site/` must not match a page URL ignoring
  case: `LICENSE` and the page `/license/` once made `jekyll serve` fail with `Operation not permitted` while unlinking
  `_site/LICENSE` (a directory, to macOS). `LICENSE` is now in `exclude:`, and `bin/check-content` reports such clashes.
  After fixing one, delete `_site/` once (`rm -rf _site .jekyll-cache`) and rebuild.
- **Never commit** `_site/`, caches, editor folders or OS files.

## PDFs and Git LFS

`.gitattributes` once declared `*.pdf filter=lfs`, but the repository history holds the PDFs as ordinary blobs (no LFS
pointers). Declaring LFS without using it can make `git status` report every PDF as modified on machines with `git-lfs`
installed (the clean filter turns each PDF into a pointer that differs from the stored blob). `.gitattributes` now says what is true: `*.pdf binary`.

The PDFs add up to about 245 MB. If the repository grows uncomfortable, the options are (a) compress the PDFs, or
(b) migrate to real LFS with `git lfs migrate import --include="*.pdf" --everything` followed by a force push and
`lfs: true` in the CI checkout. (b) rewrites history and uses GitHub's LFS quota; do not do it casually.

## Bundler, lockfile and Ruby

- `Gemfile.lock` lists about 20 platforms (Android, musl, mingw, ...) because dependencies were resolved with a broad
  platform set. Only a few are needed. With Bundler installed, trim it:

  ```sh
  bundle lock --add-platform ruby x86_64-linux arm64-darwin x86_64-darwin
  bundle lock --remove-platform aarch64-linux-android aarch64-linux-musl aarch64-mingw-ucrt arm-linux-androideabi \
    arm-linux-gnueabihf arm-linux-musleabihf riscv64-linux-android riscv64-linux-gnu riscv64-linux-musl \
    x86_64-linux-android x86_64-linux-musl x86-linux-gnu x86-linux-musl arm-linux-gnu arm-linux-musl
  ```

  Then run `bundle exec jekyll build` and review the diff. Keep `x86_64-linux` (the CI runner) in the list.
- `.ruby-version` (3.4.1) is what CI uses. Check that your local `ruby -v` matches; a different major version (the
  gems found under `vendor/bundle/ruby/4.0.0` suggest Ruby 4.0) can build differently from CI.
- `Gemfile` keeps `csv` and `logger` for Ruby 3.4+ compatibility.

## CI (`.github/workflows/jekyll.yml`)

`ruby bin/check-content` -> `bundle exec jekyll build` (`JEKYLL_ENV=production`) -> `ruby bin/check-site` (internal
links, images and scripts in the built site) -> upload and deploy on pushes to `main`. A failure in any step blocks the
deploy. Dependabot proposes gem and GitHub Actions updates weekly (`.github/dependabot.yml`).

A second workflow, `.github/workflows/links.yml`, runs every Monday (and on demand) and also checks **external** URLs
(`ruby bin/check-site --external`). It is separate because third-party sites time out and rate-limit; a red run means
a link needs attention, and it never blocks a deploy.

### `bin/check-site` (html-proofer)

```sh
gem install html-proofer --version '~> 5.0'   # once; CI installs it the same way
bundle exec jekyll build
ruby bin/check-site                            # internal only
ruby bin/check-site --external                 # plus external URLs (slow)
```

It checks `Links`, `Images` and `Scripts` in `_site/`, including that every PDF linked from a page exists at its URL.
Absolute URLs to this site (canonical, feeds) are resolved against the local build (`swap_urls`). External mode only
fails on 4xx responses and ignores 429/999 and timeouts. html-proofer is installed with `gem install` rather than the
`Gemfile` so that the lockfile does not change; if you prefer it pinned there, run `bundle add html-proofer --group test`
and drop the install steps from both workflows.

## Licensing

- **Code** (templates, styles, scripts, tooling): MIT, in `LICENSE`.
- **Content**: the blog is study notes, summaries and reviews of other people's work, so nothing is presented as wholly
  original. Only the **author's own contribution** (wording, explanations, solutions, commentary) is licensed, under
  CC BY 4.0, declared in `_config.yml` (`content_license_name`, `content_license_url`). Third-party material is not
  covered. The default footer of **every page** (`_includes/footer.html`) says exactly that; details are at `/license/`
  (`pages/license/index.md`) and in `LICENSE-CONTENT.md` (repository only).

Front matter that changes the footer notice (first match wins; each can also be set for a whole folder with a
path-scoped entry in `defaults:`):

| Field | Footer notice |
| --- | --- |
| `license: "text"` | Replaces the notice entirely (Markdown allowed). |
| `source: "Author, Work"` | "Based on material by Author, Work, which is not covered by the license. My own writing, solutions and notes are licensed under CC BY 4.0." |
| `license_mode: own` | Plain "Text and notes are licensed under CC BY 4.0", for a page that is entirely the author's own work. |
| none (default) | "Based on third-party material, which is not covered by the license. My own writing, solutions and notes are licensed under CC BY 4.0." |

Name the real sources gradually. `ruby bin/check-content --sources` lists the documents that still have no `source`,
grouped by folder. A whole course or topic can be set at once instead of file by file:

```yaml
# _config.yml
defaults:
  - scope: { path: "_annotations/linear_algebra", type: "annotations" }
    values: { source: "Prof. Name, Linear Algebra, University (year)" }
```

The validator understands path-scoped defaults, so a covered folder disappears from the `--sources` list. Note that
embedded PDFs often reproduce third-party lists or text: the notice cannot grant rights over what the author does not
own, so if a PDF contains someone else's exercise statements or passages verbatim, check that you are allowed to
publish it. Summaries in your own words are a different matter from reproduction. This is general information, not
legal advice.

To change the license, edit the two `content_license_*` keys, `pages/license/index.md`, `LICENSE-CONTENT.md` and the
wording in `_includes/footer.html`.

## Hooks

The content validator (`ruby bin/check-content`) runs in the Git pre-commit hook and in a Claude Code hook; it blocks
only on **errors** (warnings are printed but do not block). The site check runs in the pre-push hook.

- **Git pre-commit** (`.githooks/pre-commit`): content validator, takes about a second. Hooks are not cloned with the
  repository, so enable them once per clone:

  ```sh
  git config core.hooksPath .githooks
  ```

  Skip it for a single commit with `git commit --no-verify`.
- **Git pre-push** (`.githooks/pre-push`): builds the site into `tmp/site` (so a running `jekyll serve` is not
  disturbed) and runs `bin/check-site` on it, the same internal-link check as CI. It takes as long as a build. If
  html-proofer is not installed it prints how to install it and lets the push through. Skip with `git push --no-verify`.
  It is a pre-push and not a pre-commit hook because of the build time; a Claude Code hook would also be too slow
  here, since it would rebuild after every edit.
- **Claude Code** (`.claude/settings.json`). A `PostToolUse` hook runs the validator after every `Edit`, `Write` or
  `MultiEdit`; when it finds errors it exits with status 2, which feeds the messages back to Claude so it fixes them.
  It applies to anyone running Claude Code in this repository.

## Editor settings

`.editorconfig`: UTF-8, LF, final newline, two-space indentation, trailing whitespace trimmed except in Markdown.
