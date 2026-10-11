# frozen_string_literal: true

require_relative "../test_helper"

class FooterTest < Minitest::Test
  include HtmlTesting

  LICENSE_URL = "https://creativecommons.org/licenses/by/4.0/"

  def footer(page = {})
    render_include("footer.html", {}, page: page)
  end

  def license_link(html)
    tags(html, "a").find { |a| a["rel"] == "license" }
  end

  def test_always_shows_the_copyright_line_and_the_license_details_link
    html = footer
    year = IncludeRenderer.site.time.year

    assert_includes html, "&copy; #{year} Arthur Aguiar."
    details = elements(html, "a").find { |a| a.text == "License" }
    assert_equal "/license/", details["href"]
    assert_equal "site-footer", tags(html, "footer").fetch(0)["class"]
  end

  def test_license_details_link_gets_the_baseurl
    with_config("baseurl" => "/blog") do
      details = elements(footer, "a").find { |a| a.text == "License" }

      assert_equal "/blog/license/", details["href"]
    end
  end

  def test_default_notice_says_third_party_material_is_not_covered
    text = text_of(footer)

    assert_includes text, "My own notes are under CC BY 4.0; third-party material is not."
    assert_equal LICENSE_URL, license_link(footer)["href"]
  end

  def test_source_names_the_author_of_the_original_material
    text = text_of(footer("source" => "Prof. X, Calculus"))

    assert_includes text, "Based on material by Prof. X, Calculus. My own notes are under CC BY 4.0; the original material is not."
    refute_includes text, "third-party"
  end

  def test_source_is_html_escaped
    html = footer("source" => "A & <b>B</b>")

    assert_includes html, "A &amp; &lt;b&gt;B&lt;/b&gt;"
    assert_empty tags(html, "b")
  end

  def test_license_mode_own_claims_the_whole_page
    text = text_of(footer("license_mode" => "own"))

    assert_includes text, "Licensed under CC BY 4.0."
    refute_includes text, "third-party"
    refute_includes text, "Based on"
  end

  def test_custom_license_replaces_the_notice_and_is_rendered_as_markdown
    html = footer("license" => "All rights **reserved** by [someone](https://example.com).")

    assert_includes html, "<strong>reserved</strong>"
    assert_includes tags(html, "a").map { |a| a["href"] }, "https://example.com"
    assert_nil license_link(html)
    refute_includes text_of(html), "third-party"
    refute_includes text_of(html), "CC BY"
    assert_equal 1, tags(html, "p").size, "only the footer's own <p>: the one from markdownify must be removed"
  end

  def test_license_takes_precedence_over_source_and_license_mode
    text = text_of(footer("license" => "Custom", "source" => "Somebody", "license_mode" => "own"))

    assert_includes text, "Custom"
    refute_includes text, "Somebody"
    refute_includes text, "Licensed under"
  end

  def test_source_takes_precedence_over_license_mode
    text = text_of(footer("source" => "Somebody", "license_mode" => "own"))

    assert_includes text, "Based on material by Somebody"
    refute_includes text, "Licensed under"
  end

  def test_unknown_license_mode_falls_back_to_the_default_notice
    assert_includes text_of(footer("license_mode" => "whatever")), "third-party material is not"
  end
end
