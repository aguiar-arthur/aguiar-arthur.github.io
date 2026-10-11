# Tests

Unit tests for the reusable pieces: the Liquid includes in `_includes/` (Ruby, Minitest) and the client-side script
`assets/js/content-index.js` (Node, `node:test` + jsdom). They sit next to the content checks, they do not replace them:
`ruby bin/check-content` still validates content and `bundle exec jekyll build` + `bin/check-site` still validate the
built site.

```sh
bundle install                 # once (and after Gemfile changes); adds minitest and rake
bundle exec rake test          # include tests (Ruby)
npm ci                         # once; installs jsdom into node_modules/ (git-ignored)
npm test                       # content-index.js tests (Node 22)
bundle exec rake test:all      # both
```

A single file: `bundle exec ruby -Itest test/includes/file_list_test.rb`; a single test: add `-n test_name`.

## Layout

```text
test/
  test_helper.rb            Minitest setup + HtmlTesting helpers (tags, elements, text_of, render_include, with_config)
  support/include_renderer.rb   renders an include through the real Jekyll/Liquid (loads _config.yml, no site build)
  support/render_include.rb     CLI around the renderer: prints an include's HTML (used by the Node tests)
  includes/*_test.rb        one file per include
  js/*.test.mjs             Node tests for assets/js
Rakefile                    `rake test`, `rake test:js`, `rake test:all`
package.json                only devDependencies (jsdom) and the `test` script
```

## How the include tests work

`IncludeRenderer.render("file-list.html", files: [...], base: "/papers/x/", page: { "source" => "..." })` runs
`{% include file-list.html ... %}` with a real `Jekyll::Site` (built from `_config.yml`, theme and plugins removed), so
filters like `relative_url` and `markdownify` behave as in a build. Parameters are passed as Liquid variables, so arrays
and hashes work. `page:` is what the include sees as `page` (front matter). `with_config("baseurl" => "/blog") { ... }`
overrides site settings for the block (and clears Jekyll's `relative_url` cache).

Assertions use small helpers instead of an HTML parser dependency: `tags(html, "a")` (attribute hashes of every start
tag), `elements(html, "li")` (attributes + inner HTML, for elements that do not nest in themselves) and
`text_of(html)` (visible text). Prefer asserting on structure and text, not on whole-string equality.

Covered: `file-list`, `footer`, `list`, `warning`, `pdf-viewer`, `content-index`. Not covered on purpose: `mathjax`
(static script tag) and `head` (needs the feed and SEO plugins; it is exercised by the build itself).

## How the JavaScript tests work

`test/js/content-index.test.mjs` asks Ruby for the real HTML of `content-index.html` (25 and 3 items), loads it in
jsdom, evaluates `assets/js/content-index.js` and drives it with `input` and `click` events. Because the markup comes from
the include, a change that breaks the script's `data-index-*` hooks or the `data-search` text fails here.

## When you change something

- **Include**: update or add its test in the same commit, and `docs/includes.md`.
- **New include**: add `test/includes/<name>_test.rb` (copy a small one, for example `warning_test.rb`).
- **`content-index.js` or `content-index.html`**: run both suites.

## Automatic runs

`ruby bin/run-tests` is the single entry point (Ruby tests, then the JavaScript ones when `node_modules/` exists).
It prints one line on success and the failing output on stderr (exit 2) otherwise.

| Where | When | Command |
| --- | --- | --- |
| Claude Code `PostToolUse` hook (`.claude/settings.json`) | after every Edit/Write/MultiEdit, only if the edited file is under `_includes/`, `assets/js/`, `test/` or is `Rakefile`, `package*.json`, `Gemfile*`, `_config.yml` | `bin/run-tests --hook` |
| Git pre-commit (`.githooks/pre-commit`) | after `bin/check-content`, only if a staged file matches the same list | `bin/run-tests --staged` |
| Git pre-push (`.githooks/pre-push`) | always, before the build and the link check | `bin/run-tests` |
| CI job `test` (`.github/workflows/jekyll.yml`) | every push and pull request, in parallel with `build`; `deploy` `needs: [test, build]` | `bundle exec rake test`, `npm ci`, `npm test` |

In the hook and pre-commit modes missing tooling (no `bundle install` or `npm ci` yet) is a warning, not a failure, so
a fresh clone is not blocked; the pre-push hook and CI always run everything they can. `--dry-run` shows what a mode
would do without running it.

## Gotchas

- `Liquid` caches parsed templates by file name inside a site, so the renderer names each template after its source;
  reusing one name for different sources would silently render the first one again.
- `relative_url` memoizes per input string; `with_config` clears it. Do not set `site.config["baseurl"]` by hand in a test.
- `minitest` is pinned to 5.x in the `Gemfile`: Ruby 3.4 no longer ships it as a default gem, so Bundler needs it in the
  lockfile, and 6.x depends on extra native gems.
- `test/`, `Rakefile`, `package.json`, `package-lock.json` and `node_modules/` are in `exclude:` in `_config.yml`.
