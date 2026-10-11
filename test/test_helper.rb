# frozen_string_literal: true

require "cgi"
require "minitest/autorun"
require_relative "support/include_renderer"

# Helpers shared by the include tests. `include HtmlTesting` in a test class.
#
# The includes emit small, regular HTML, so assertions use a few tiny helpers instead of an HTML
# parser dependency: `tags` (start-tag attributes), `elements` (attributes + inner HTML, for
# elements that do not nest inside themselves) and `text_of` (visible text).
module HtmlTesting
  Element = Struct.new(:attrs, :inner) do
    def [](name)
      attrs[name]
    end

    def text
      HtmlTesting.text_of(inner)
    end
  end

  def self.text_of(html)
    inline = html.gsub(%r{</?(?:a|b|i|em|strong|span|code)(?=[\s>/])[^>]*>}m, "")
    CGI.unescapeHTML(inline.gsub(/<[^>]*>/m, " ")).gsub(/\s+/, " ").strip
  end

  def self.parse_attrs(source)
    source.scan(/([^\s=\/>"']+)(?:\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+)))?/m).to_h do |name, double, single, bare|
      [name, CGI.unescapeHTML(double || single || bare || "")]
    end
  end

  # Parameters can be passed as a Hash or as keywords: render_include("x.html", file: "a.pdf").
  def render_include(name, params = {}, page: {}, **inline)
    IncludeRenderer.render(name, params.merge(inline), page: page)
  end

  def with_config(overrides, &block)
    IncludeRenderer.with_config(overrides, &block)
  end

  # Attributes of every start tag called `name`, in document order.
  def tags(html, name)
    html.scan(/<#{name}(?=[\s>\/])([^>]*)>/m).map { |(source)| HtmlTesting.parse_attrs(source) }
  end

  # Every `<name ...>inner</name>`, in document order (do not use for elements nested in themselves).
  def elements(html, name)
    html.scan(%r{<#{name}(?=[\s>])([^>]*)>(.*?)</#{name}>}m).map do |source, inner|
      Element.new(HtmlTesting.parse_attrs(source), inner)
    end
  end

  def text_of(html)
    HtmlTesting.text_of(html)
  end

  def squish(html)
    html.gsub(/\s+/, " ").gsub(/> </, "><").strip
  end
end
