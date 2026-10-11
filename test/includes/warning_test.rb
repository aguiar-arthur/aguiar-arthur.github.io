# frozen_string_literal: true

require_relative "../test_helper"

class WarningTest < Minitest::Test
  include HtmlTesting

  def test_renders_a_note_box_with_title_and_text
    html = render_include("warning.html", title: "About the language", text: "This document is in pt-br.")

    box = tags(html, "div").fetch(0)
    assert_equal "notice notice--warning", box["class"]
    assert_equal "note", box["role"] # static information: not an alert that interrupts screen readers
    title = elements(html, "p").fetch(0)
    assert_equal "notice__title", title["class"]
    assert_equal "About the language", title.text
    assert_includes title.inner, "<strong>"
    assert_empty tags(html, "h6") # no heading: it would break the page outline
    assert_includes text_of(html), "This document is in pt-br."
  end

  def test_language_defaults_to_the_site_language_and_can_be_overridden
    assert_equal "en", tags(render_include("warning.html", text: "x"), "div").fetch(0)["lang"]
    assert_equal "pt-BR", tags(render_include("warning.html", text: "x", lang: "pt-BR"), "div").fetch(0)["lang"]
  end

  def test_title_is_optional
    html = render_include("warning.html", text: "Only text")

    assert_empty tags(html, "p")
    assert_includes text_of(html), "Only text"
  end

  def test_text_is_rendered_as_markdown_without_a_wrapping_paragraph
    html = render_include("warning.html", text: "This is **important** and has a [link](https://example.com).")

    assert_includes html, "<strong>important</strong>"
    assert_equal "https://example.com", elements(html, "a").fetch(0)["href"]
    assert_empty tags(html, "p") # no title given: the only possible <p> would be markdownify's wrapper
  end

  def test_content_container
    html = render_include("warning.html", text: "x")

    assert_equal 1, tags(html, "div").count { |t| t["class"] == "notice__content" }
  end
end
