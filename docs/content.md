# Content conventions and validation

## Front matter

```yaml
---
layout: post
title:  "Quoted title"
date:   2026-06-28 10:00:00
categories: ["Mathematics"]
tags: ["Pre Calculus"]
---
```

- `title`, `date` and `categories` (a list) are required for posts, annotations and books. Group pages
  (`layout: group`) need `title` and `date` only. Optional licensing fields: `source`, `license_mode` (`own` or
  `derived`) and `license` (see [repository.md](repository.md#licensing)). The default notice says the page is based on third-party material; `license_mode: own` marks an entirely original page.
- Categories and tags come from the fixed list in `_data/taxonomy.yml` (add a new one there in the same commit); do not create near-duplicates
  (`Mathematics` vs `mathematics`).
- The front-matter `date`, not the file name, is what the site shows and sorts by. Keep them equal. Dates without a
  zone are read in the site's `timezone` (`America/Sao_Paulo` in `_config.yml`), so local and CI builds agree.
- File names: `YYYY-MM-DD-slug.md` (annotations may use `YY-MM-DD-`, but prefer four digits).
- URLs come from the file name: annotations and books use the file path, posts use the file-name slug (not the
  title). **Renaming a file changes its URL** and breaks old links (nothing redirects). The two typos found
  (`firts-exam`, `learnig`) were renamed on 2026-10-08.

## Validator: `bin/check-content`

```sh
ruby bin/check-content
```

Standard library only; it runs in CI before the build (`.github/workflows/jekyll.yml`) and takes about a second.

| Level | Checks |
| --- | --- |
| **Error** (exit 1, fails CI) | Missing or invalid front matter, missing `title`/`date`/`categories`, unparsable date, any `/assets/...` path that does not exist, a group's declared file that does not exist, a category or tag missing from `_data/taxonomy.yml`, upper-case or spaced file names, git tracking a different case than the disk. |
| **Warning** | Unknown front matter key (catches typos like `gategories`), `categories` not a list, date different from the file name, category/tag spelled in more than one way, asset not referenced anywhere, math without `mathjax.html` (or the include without math), `<img>` without `alt`, a PDF in a group folder that is not declared, a title or `Course - Topic` topic starting in lower case, a new file name with a 2-digit year (the 28 old ones are listed in `bin/legacy-short-dates.txt`). |

Run `ruby bin/check-content --sources` to list annotations that do not name the author of their source material.

Add a new known key to `KNOWN_KEYS` in the script when you introduce one.

## Taxonomy pages

`pages/posts/`, `pages/annotations/` and `pages/books/` each have `tags.html` and `categories.html`. Posts use `site.tags` /
`site.categories` (sorted by name); annotations and books build the lists from their own collection, since
Jekyll's `site.tags` only contains posts. Papers have no taxonomy pages: groups are listed on
`pages/papers/principal.html`.

## Feeds

`jekyll-feed` publishes `/feed.xml` (posts) plus `/annotations/feed.xml`, `/books/feed.xml` and
`/papers/feed.xml` (see `feed:` in `_config.yml`). Only `/feed.xml` is advertised in the page head.

## Things deliberately not done

Large or destructive changes were left out and need a decision: compressing the PDFs (245 MB, some above 20 MB),
converting the JPEG annotations to WebP, a full-text search such as Pagefind, trimming `Gemfile.lock` platforms, and naming real `source:` authors per course.
