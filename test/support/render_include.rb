# frozen_string_literal: true

# Prints the HTML of one include, for tests written in other languages.
#
#   bundle exec ruby test/support/render_include.rb content-index.html '{"id":"x","items":[...]}'

require "json"
require_relative "include_renderer"

name, json = ARGV
abort "usage: render_include.rb <include.html> [params-json]" unless name

params = JSON.parse(json || "{}")
print IncludeRenderer.render(name, params)
