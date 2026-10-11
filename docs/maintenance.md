# Maintenance

Commands, repository hygiene, CI, hooks and tests. See [content.md](content.md) for writing and [site.md](site.md)
for templates.

## Commands

Run everything from the repository root (Jekyll run from a subfolder builds an unstyled mini-site).

```sh
bundle install                 # Ruby version in .ruby-version
bundle exec jekyll serve       # http://127.0.0.1:4000; restart after editing _config.yml
bundle exec jekyll build       # output in _site/
ruby bin/check-content         # content validator
bundle exec rake test          # unit tests (Minitest)
ruby bin/run-tests             # the tests, as the hooks run them
ruby bin/check-site            # html-proofer on _site/ (gem install html-proofer --version '~> 5.0')
git config core.hooksPath .githooks   # once per clone
```

## Repository hygiene

- **Never commit** `_site/`, `.jekyll-cache/`, `.sass-cache/`, `.bundle/`, `vendor/`, `tmp/` (all git-ignored).
  Where gems are installed is a local choice (`bundle config set --local path vendor/bundle` keeps them in the project).
- **Case**: names in content directories are lowercase, and git must track the disk's case (macOS hides case-only
  renames; fix with `git mv -f Old new`). Page URLs must not collide, ignoring case, with root files copied to `_site/`:
  that is why `LICENSE` is in `exclude:` next to `/license/`. After fixing a clash, `rm -rf _site .jekyll-cache`.
- **PDFs** are plain binaries (`.gitattributes`: `*.pdf binary`), not Git LFS, about 245 MB. If a local config still
  applies `filter=lfs`, `git status` lists every PDF as modified: a tooling mismatch, do not stage them. Moving to real
  LFS (`git lfs migrate import --include="*.pdf" --everything`) rewrites history; do not do it casually.
- **Ruby/Bundler**: CI uses `.ruby-version`; match it locally. Keep `csv` and `logger` in the Gemfile (no longer default
  gems since Ruby 3.4). `minitest` stays on 5.x. `Gemfile.lock` lists more platforms than needed; keep `x86_64-linux`
  (CI) if you trim it.
- **Not published**: `docs/`, `bin/`, `test/`, `Rakefile`, `AGENTS.md`, `CLAUDE.md`, `README.md` are in `exclude:`.
  `bin/` must stay versioned (CI runs it).
- `.editorconfig`: UTF-8, LF, final newline, two spaces, trailing whitespace trimmed except in Markdown.

## CI

`.github/workflows/jekyll.yml` on every push and pull request to `main`:

- `test`: `bundle exec rake test`.
- `build`: `bin/check-content` → `jekyll build` (`JEKYLL_ENV=production`) → `bin/check-site` (internal links, images,
  scripts, including every linked PDF) → Pages artifact.
- `deploy`: only on push to `main`, `needs: [test, build]`. **Pushing to `main` publishes the site.**

The workflow has `contents: read` (only `deploy` gets `pages`/`id-token: write`), checkouts don't persist credentials,
every job has a timeout, pull-request runs cancel their previous run and deployments never interrupt each other.
`.github/workflows/links.yml` checks external links every Monday (`bin/check-site --external`) and never blocks.
Dependabot groups weekly minor/patch updates of gems and actions.

`bin/check-site` resolves absolute URLs to this site against the local build; external mode fails only on 4xx and
ignores 429/999 and timeouts. html-proofer is installed with `gem install` so the lockfile does not change.

## Hooks

| Hook | When | Runs |
| --- | --- | --- |
| Claude Code `PostToolUse` (`.claude/settings.json`) | after every Edit, Write, MultiEdit and Bash call | `bin/check-content`, then `bin/run-tests --hook`; exit 2 feeds errors back to Claude |
| Git pre-commit (`.githooks/pre-commit`) | every commit | `bin/check-content`, then `bin/run-tests --staged` |
| Git pre-push (`.githooks/pre-push`) | every push | all tests, a build into `tmp/site`, `bin/check-site` (skipped with a notice without html-proofer) |

Only errors block; warnings are printed. Skip a Git hook once with `--no-verify`.

`bin/run-tests` runs the tests only when a changed file can affect them (`_includes/`, `bin/check-content`, `test/`,
`Rakefile`, `Gemfile*`, `_config.yml`). After a Bash call it looks at what git sees as changed and skips if nothing
relevant changed since the last green run (fingerprint in `tmp/run-tests-hook.fingerprint`). Missing gems are a
warning in the hook and pre-commit modes, so a fresh clone is not blocked. It reads the hook JSON as UTF-8 whatever
the locale. `--dry-run` shows what it would do.

## Tests

```sh
bundle exec rake test
bundle exec ruby -Itest test/includes/file_list_test.rb -n test_name   # one test
```

- `test/includes/*_test.rb`: one file per include. `IncludeRenderer` (`test/support/`) renders
  `{% include ... %}` with a real `Jekyll::Site` built from `_config.yml` (theme and plugins removed), so
  `relative_url` and `markdownify` behave as in a build. `render_include(name, params, page: {...})` sets what the
  include sees as `page`; `with_config("baseurl" => "/blog") { ... }` overrides site settings and clears Jekyll's
  `relative_url` cache.
- Assertions use small helpers instead of an HTML parser: `tags` (start-tag attributes), `elements` (attributes and
  inner HTML), `text_of`, and `Element#visible_text` (text without `.visually-hidden` parts).
- `test/bin/check_content_test.rb` runs the validator against a scratch site (`CHECK_CONTENT_ROOT`), one rule per test.
- Not covered: `mathjax.html` (a script tag), `head.html` (needs the plugins; the build exercises it) and
  `assets/js/content-index.js` (check search and pagination by hand in `jekyll serve`).

When you change an include or a validator rule, update its test in the same commit. Liquid caches templates by
name, so the renderer names each one after its source; reusing a name for different sources would render the first.
