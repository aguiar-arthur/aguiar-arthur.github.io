# Layouts (`_layouts/`)

Four layouts live in the project. `default` and `post` replace the ones from the `no-style-please`
theme gem, so the site does not depend on the theme's markup.

## Which layout does a page use?

| Content | Layout | Set by |
| --- | --- | --- |
| `_posts`, `_annotations`, `_books`, `_papers` documents | `post` | `defaults:` in `_config.yml` (also written in front matter) |
| `index.markdown` (landing page) | `home` | its front matter |
| Group index in a collection (`_papers/<slug>/index.md`) | `group` | its front matter |
| `posts/principal.html`, `*/tags.html`, `*/categories.html`, `about/index.html` | `post` | their front matter |
| `404.html` | `default` | its front matter |

Chain: `group` -> `post` -> `default`; `home` -> `default`.

## `default.html`

The HTML shell: `<html lang>` (from `page.lang`, then `site.lang`, then `en`), the `head.html` include and a
`.page-content > .wrapper` container around `{{ content }}`. The wrapper width (640px) comes from the theme's CSS.

## `post.html`

Used by all content documents and plain pages: a "&larr; Home" link, the `<h1>` title and, for collection
documents (not groups, not plain pages), the date in a `<p class="post-meta">` with a `<time>` element.

## `home.html`

The landing page. Wraps `default`, with a skip link, the site title, the main navigation
(Posts, Annotations, Books, Papers, About me), then (inside `<div id="content">`, the skip link's target):

- **Latest Posts**: the 5 most recent `site.posts` (already newest first), via `list.html`.
- **Latest Annotations**: 3 most recent `site.annotations` (sorted by `date`, newest first), with a
  fallback message when empty.
- Footer with the copyright year.

To add a navigation entry, add an `<a href="{{ "/x/" | relative_url }}">` in the `<nav>`. Books and papers are
not shown as "latest" sections.

## `group.html`

A reusable "folder of documents" page. Wraps `post`, so the title and base styling come from the theme.

Front matter it understands:

| Key | Effect |
| --- | --- |
| `title` | Page title (rendered by the parent layout). |
| `description` | Intro paragraph (`<p class="group-intro">`). Also used as the meta description by the SEO tag. |
| `lang` | If present and not `en`, shows the "About the language" notice (no English translation). |
| `files` | Documents to list (see [`file-list.html`](includes.md#file-listhtml)). Only these are listed. |

Order on the page: back link and title (from `post`), language notice -> description -> body of the `index.md` -> file list. Anything you
write in the Markdown body appears between the description and the list.

Works in any collection or page, not only papers:

```yaml
---
layout: group
title: "Some topic"
date: 2026-10-08 00:00:00
permalink: /books/some-topic/
description: "Short intro."
files:
  - file: "notes.pdf"
    title: "Notes"
---
```
