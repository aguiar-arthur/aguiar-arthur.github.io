# frozen_string_literal: true

require_relative "../test_helper"

class ListTest < Minitest::Test
  include HtmlTesting

  def render(items, **params)
    render_include("list.html", { items: items }.merge(params))
  end

  def test_items_with_url_become_links
    html = render([{ title: "About", url: "/about/" }, { title: "Home", url: "/" }])

    links = elements(html, "a")
    assert_equal ["About", "Home"], links.map(&:text)
    assert_equal ["/about/", "/"], links.map { |l| l["href"] }
    assert_equal 2, tags(html, "li").size
  end

  def test_site_relative_urls_get_the_baseurl
    with_config("baseurl" => "/blog") do
      assert_equal "/blog/about/", elements(render([{ title: "About", url: "/about/" }]), "a").fetch(0)["href"]
    end
  end

  def test_absolute_urls_are_left_alone
    with_config("baseurl" => "/blog") do
      html = render([{ title: "GitHub", url: "https://github.com/aguiar-arthur" }])

      assert_equal "https://github.com/aguiar-arthur", elements(html, "a").fetch(0)["href"]
    end
  end

  def test_item_without_url_is_plain_text
    html = render([{ title: "Just text" }])

    assert_empty tags(html, "a")
    assert_equal "Just text", elements(html, "li").fetch(0).text
  end

  def test_default_classes
    html = render([{ title: "A", url: "/a/" }])

    assert_equal "list", tags(html, "ul").fetch(0)["class"] # once, not "list list"
    assert_equal "list__item", tags(html, "li").fetch(0)["class"]
  end

  def test_custom_list_and_item_classes
    html = render([{ title: "A", url: "/a/" }], class: "social-links", item_class: "social-links__item")

    assert_includes tags(html, "ul").fetch(0)["class"].split, "social-links"
    assert_includes tags(html, "li").fetch(0)["class"].split, "social-links__item"
  end

  def test_empty_or_missing_items_render_nothing
    assert_empty render([]).strip
    assert_empty render_include("list.html").strip
  end
end
