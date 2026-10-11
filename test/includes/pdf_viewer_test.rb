# frozen_string_literal: true

require_relative "../test_helper"

class PdfViewerTest < Minitest::Test
  include HtmlTesting

  FILE = "/assets/pdfs/cdi_one/functions_introduction.pdf"

  def test_defaults
    html = render_include("pdf-viewer.html", file: FILE)

    viewer = tags(html, "object").fetch(0)
    assert_equal FILE, viewer["data"]
    assert_equal "application/pdf", viewer["type"]
    assert_equal "800px", viewer["height"]
    assert_equal "100%", viewer["width"]
    assert_equal "PDF document", viewer["aria-label"]
  end

  def test_height_and_title_can_be_customised
    html = render_include("pdf-viewer.html", file: FILE, height: "1000px", title: "Linear algebra, list 1")

    viewer = tags(html, "object").fetch(0)
    assert_equal "1000px", viewer["height"]
    assert_equal "Linear algebra, list 1", viewer["aria-label"]
  end

  def test_open_link_and_fallback_link_point_to_the_pdf_in_a_new_tab
    links = tags(render_include("pdf-viewer.html", file: FILE), "a")

    assert_equal 2, links.size
    links.each do |link|
      assert_equal FILE, link["href"]
      assert_equal "_blank", link["target"]
      assert_equal "noopener noreferrer", link["rel"]
    end
  end

  def test_open_card_comes_before_the_embedded_object
    html = render_include("pdf-viewer.html", file: FILE)

    assert_operator html.index("pdf-viewer__open-card"), :<, html.index("<object")
    assert_includes elements(html, "a").map(&:visible_text), "Open PDF"
  end

  def test_links_name_the_document_and_the_new_tab_for_screen_readers
    links = elements(render_include("pdf-viewer.html", file: FILE, title: "List 1"), "a")

    links.each { |link| assert_equal "Open PDF: List 1 (opens in a new tab)", link.text }
  end

  def test_title_defaults_to_the_page_title
    html = render_include("pdf-viewer.html", { file: FILE }, page: { title: "CDI one - Limits" })

    assert_equal "CDI one - Limits", tags(html, "object").fetch(0)["aria-label"]
  end

  def test_english_text_is_marked_as_english_on_pages_in_other_languages
    html = render_include("pdf-viewer.html", { file: FILE }, page: { lang: "pt-BR" })

    assert_equal "en", tags(html, "a").fetch(0)["lang"]
    assert_equal "en", tags(html, "p").fetch(0)["lang"]
  end

  def test_fallback_message_is_inside_the_object
    inner = elements(render_include("pdf-viewer.html", file: FILE), "object").fetch(0).inner

    assert_includes text_of(inner), "Your browser cannot display this PDF."
  end

  def test_baseurl_is_applied_everywhere
    with_config("baseurl" => "/blog") do
      html = render_include("pdf-viewer.html", file: FILE)

      assert_equal "/blog#{FILE}", tags(html, "object").fetch(0)["data"]
      assert_equal ["/blog#{FILE}"] * 2, tags(html, "a").map { |a| a["href"] }
    end
  end
end
