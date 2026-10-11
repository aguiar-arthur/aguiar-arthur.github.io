# frozen_string_literal: true

require_relative "../test_helper"

class FileListTest < Minitest::Test
  include HtmlTesting

  def render(files, **params)
    render_include("file-list.html", { files: files }.merge(params))
  end

  def links(html)
    elements(html, "a")
  end

  def test_string_entry_is_resolved_against_base_and_title_comes_from_the_file_name
    html = render(["intro-to-monads.pdf"], base: "/papers/monads/")

    link = links(html).fetch(0)
    assert_equal "/papers/monads/intro-to-monads.pdf", link["href"]
    assert_equal "Intro to monads", link.visible_text
  end

  def test_underscores_and_directories_are_cleaned_up_in_derived_titles
    html = render(["slides/my_first-file.pdf"], base: "/g/")

    link = links(html).fetch(0)
    assert_equal "/g/slides/my_first-file.pdf", link["href"]
    assert_equal "My first file", link.visible_text
  end

  def test_explicit_title_wins_over_the_file_name
    html = render([{ file: "x.pdf", title: "Título explícito" }], base: "/g/")

    link = links(html).fetch(0)
    assert_equal "/g/x.pdf", link["href"]
    assert_equal "Título explícito", link.visible_text
  end

  def test_hash_entry_without_title_derives_it_from_the_file_name
    html = render([{ file: "relatorio-final.pdf" }], base: "/g/")

    assert_equal "Relatorio final", links(html).fetch(0).visible_text
  end

  def test_entry_starting_with_slash_ignores_base
    html = render(["/assets/pdfs/topic/doc.pdf"], base: "/papers/monads/")

    assert_equal "/assets/pdfs/topic/doc.pdf", links(html).fetch(0)["href"]
  end

  def test_missing_base_defaults_to_the_site_root
    html = render(["doc.pdf"])

    assert_equal "/doc.pdf", links(html).fetch(0)["href"]
  end

  def test_baseurl_is_prepended_to_every_link
    with_config("baseurl" => "/blog") do
      html = render(["a.pdf", "/assets/b.pdf"], base: "/papers/x/")

      assert_equal ["/blog/papers/x/a.pdf", "/blog/assets/b.pdf"], links(html).map { |l| l["href"] }
    end
  end

  def test_custom_extension_is_stripped_from_derived_titles
    html = render(["notes.md"], base: "/g/", ext: ".md")

    assert_equal "Notes", links(html).fetch(0).visible_text
  end

  def test_links_open_in_a_new_tab_safely
    link = links(render(["a.pdf"], base: "/g/")).fetch(0)

    assert_equal "_blank", link["target"]
    assert_equal "noopener noreferrer", link["rel"]
  end

  def test_links_tell_screen_readers_they_open_a_new_tab
    link = links(render(["a.pdf"], base: "/g/")).fetch(0)

    assert_equal "A (opens in a new tab)", link.text
    assert_equal "A", link.visible_text
    assert_equal "en", tags(link.inner, "span").fetch(0)["lang"]
  end

  def test_entries_keep_their_declared_order
    html = render(["b.pdf", "a.pdf", "c.pdf"], base: "/g/")

    assert_equal ["B", "A", "C"], links(html).map(&:visible_text)
  end

  def test_divider_splits_the_list_in_two_lists_with_a_heading_between
    html = squish(render(["a.pdf", { divider: "Part two" }, "b.pdf"], base: "/g/"))

    assert_equal 2, tags(html, "ul").size
    headings = elements(html, "h2")
    assert_equal ["Part two"], headings.map(&:text)
    assert_equal "file-list__divider", headings.fetch(0)["class"]
    assert_operator html.index(">A<span"), :<, html.index("Part two")
    assert_operator html.index("Part two"), :<, html.index(">B<span")
  end

  def test_leading_and_trailing_dividers_do_not_create_empty_lists
    html = render([{ divider: "First" }, "a.pdf", { divider: "Last" }], base: "/g/")

    assert_equal 1, tags(html, "ul").size
    assert_equal ["First", "Last"], elements(html, "h2").map(&:text)
  end

  def test_consecutive_dividers_do_not_create_empty_lists
    html = render([{ divider: "One" }, { divider: "Two" }, "a.pdf"], base: "/g/")

    assert_equal 1, tags(html, "ul").size
    assert_equal 2, tags(html, "h2").size
  end

  def test_lists_are_balanced
    html = render(["a.pdf", { divider: "X" }, "b.pdf", "c.pdf"], base: "/g/")

    assert_equal html.scan("<ul").size, html.scan("</ul>").size
    assert_equal html.scan("<li").size, html.scan("</li>").size
  end

  def test_list_markup_uses_the_site_list_classes
    html = render(["a.pdf"], base: "/g/")

    assert_includes tags(html, "ul").fetch(0)["class"].split, "file-list"
    assert_equal "list__item", tags(html, "li").fetch(0)["class"]
    assert_equal 1, tags(html, "div").count { |t| t["class"] == "file-list-group" }
  end

  def test_empty_list_renders_a_placeholder
    assert_equal "No documents yet.", text_of(render([]))
    assert_empty tags(render([]), "ul")
  end

  def test_missing_files_parameter_renders_the_placeholder
    assert_equal "No documents yet.", text_of(render_include("file-list.html"))
  end
end
