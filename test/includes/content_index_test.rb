# frozen_string_literal: true

require_relative "../test_helper"

class ContentIndexTest < Minitest::Test
  include HtmlTesting

  ITEMS = [
    { title: "Pre Calculus - List One", url: "/annotations/pre_calculus/list-one/", date: Time.utc(2026, 3, 22),
      categories: ["Mathematics"], tags: ["Pre Calculus", "CDI one"] },
    { title: "Zero Copy", url: "/posts/2024/09/07/zero-copy/", date: Time.utc(2024, 9, 7),
      categories: ["Computer Science"], tags: [] },
    { title: "No taxonomy", url: "/books/no-taxonomy/", date: Time.utc(2025, 1, 2) }
  ].freeze

  def render(items = ITEMS, **params)
    render_include("content-index.html", { id: "posts", items: items }.merge(params))
  end

  def entries(html)
    elements(html, "li")
  end

  def test_renders_one_entry_per_item_in_the_given_order
    items = entries(render).select { |li| li.attrs.key?("data-index-item") }

    assert_equal 3, items.size
    assert_equal ["Pre Calculus - List One", "Zero Copy", "No taxonomy"], items.map { |li| elements(li.inner, "a").fetch(0).text }
  end

  def test_each_entry_links_to_the_item_and_shows_its_date
    li = entries(render).fetch(0)
    link = elements(li.inner, "a").fetch(0)

    assert_equal "/annotations/pre_calculus/list-one/", link["href"]
    assert_equal "March 22, 2026", elements(li.inner, "p").fetch(0).text
  end

  def test_baseurl_is_applied_to_item_links
    with_config("baseurl" => "/blog") do
      link = elements(entries(render).fetch(1).inner, "a").fetch(0)

      assert_equal "/blog/posts/2024/09/07/zero-copy/", link["href"]
    end
  end

  def test_search_text_is_lowercase_and_contains_title_date_categories_and_tags
    search = entries(render).fetch(0)["data-search"]

    assert_equal "pre calculus - list one march 22, 2026 mathematics pre calculus cdi one", search
  end

  def test_search_text_for_items_without_categories_or_tags
    search = entries(render).fetch(2)["data-search"]

    assert_equal "no taxonomy january 02, 2025", search
  end

  def test_search_text_is_a_single_line_so_queries_can_span_fields
    ITEMS.each_index do |index|
      refute_match(/\s{2,}|[\r\n]/, entries(render).fetch(index)["data-search"])
    end
  end

  def test_search_text_is_attribute_safe
    items = [{ title: 'Tom & "Jerry" <b>', url: "/x/", date: Time.utc(2026, 1, 1) }]
    li = tags(render(items), "li").find { |t| t.key?("data-index-item") }

    assert_includes li["data-search"], 'tom & "jerry" <b>'
  end

  def test_search_input_and_label_are_linked_through_the_id
    html = render(id: "papers")

    input = tags(html, "input").fetch(0)
    label = tags(html, "label").fetch(0)
    assert_equal "content-search-papers", input["id"]
    assert_equal "content-search-papers", label["for"]
    assert_equal "search", input["type"]
    assert input.key?("data-index-search")
  end

  def test_hooks_used_by_the_script_are_present
    html = render

    %w[data-index-list data-index-no-results data-index-pagination data-index-previous data-index-next data-index-status].each do |hook|
      assert_equal 1, html.scan(/\s#{hook}[\s>=]/).size, "missing #{hook}"
    end
    assert_equal "10", tags(html, "div").find { |d| d["class"] == "content-index" }["data-per-page"]
  end

  def test_no_results_message_and_pagination_start_hidden
    html = render

    assert tags(html, "p").find { |p| p.key?("data-index-no-results") }.key?("hidden")
    assert tags(html, "nav").fetch(0).key?("hidden")
  end

  def test_empty_items_render_the_default_message
    ["items", nil].each do |mode|
      html = mode ? render([]) : render_include("content-index.html", id: "posts")
      lis = entries(html)

      assert_equal 1, lis.size
      assert lis.fetch(0).attrs.key?("data-index-empty")
      refute lis.fetch(0).attrs.key?("data-index-item")
      assert_equal "No items available yet.", lis.fetch(0).text
    end
  end

  def test_empty_message_can_be_customised
    html = render([], empty_message: "Nothing here yet.")

    assert_equal "Nothing here yet.", entries(html).fetch(0).text
  end

  def test_loads_the_script_deferred_from_the_site_assets
    with_config("baseurl" => "/blog") do
      script = tags(render, "script").fetch(0)

      assert_equal "/blog/assets/js/content-index.js", script["src"]
      assert script.key?("defer")
    end
  end
end
