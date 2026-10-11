# frozen_string_literal: true

require_relative "../test_helper"

class WarningTest < Minitest::Test
  include HtmlTesting

  def test_renders_an_alert_box_with_title_and_text
    html = render_include("warning.html", title: "About the language", text: "This document is in pt-br.")

    box = tags(html, "div").fetch(0)
    assert_equal "notice notice--warning", box["class"]
    assert_equal "alert", box["role"]
    assert_equal ["About the language"], elements(html, "h6").map(&:text)
    assert_equal "notice__title", tags(html, "h6").fetch(0)["class"]
    assert_includes text_of(html), "This document is in pt-br."
  end

  def test_title_is_optional
    html = render_include("warning.html", text: "Only text")

    assert_empty tags(html, "h6")
    assert_includes text_of(html), "Only text"
  end

  def test_text_is_rendered_as_markdown_without_a_wrapping_paragraph
    html = render_include("warning.html", text: "This is **important** and has a [link](https://example.com).")

    assert_includes html, "<strong>important</strong>"
    assert_equal "https://example.com", elements(html, "a").fetch(0)["href"]
    assert_empty tags(html, "p")
  end

  def test_content_container
    html = render_include("warning.html", text: "x")

    assert_equal 1, tags(html, "div").count { |t| t["class"] == "notice__content" }
  end
end
