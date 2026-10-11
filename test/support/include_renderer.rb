# frozen_string_literal: true

# Renders a file from `_includes/` through the real Jekyll and Liquid, so filters such as
# `relative_url` and `markdownify` behave exactly as in a site build. Nothing is read from
# or written to disk: only a `Jekyll::Site` is instantiated (its `_config.yml` is loaded so
# `site.title`, `site.baseurl`, the license settings, etc. are the real ones).
#
# Used by the Minitest suite (via `test_helper.rb`).

require "jekyll"
require "tmpdir"

Jekyll.logger.log_level = :error # no "Configuration file: ..." noise (stdout is the HTML for other tools)

module IncludeRenderer
  ROOT = File.expand_path("../..", __dir__)

  class << self
    def site
      @site ||= begin
        defaults = Jekyll.configuration(
          "source" => ROOT,
          "destination" => File.join(Dir.tmpdir, "jekyll-include-tests"),
          "quiet" => true,
          "disable_disk_cache" => true,
          "skip_config_files" => true
        )
        project = Jekyll::Configuration.new.read_config_file(File.join(ROOT, "_config.yml"))
        # The theme's own includes and the plugins are not under test.
        project.delete("theme")
        project.delete("plugins")
        Jekyll::Site.new(Jekyll::Utils.deep_merge_hashes(defaults, project))
      end
    end

    # Renders `{% include <name> key=value ... %}`.
    #
    #   params: the include's parameters (Hashes and Arrays are passed as Liquid variables, so
    #           any structure works). Symbol keys are accepted everywhere.
    #   page:   what the include sees as `page` (front matter of the page being rendered).
    def render(name, params = {}, page: {})
      payload = site.site_payload
      payload["page"] = stringify(page)
      args = params.map do |key, value|
        payload["arg_#{key}"] = stringify(value)
        "#{key}=arg_#{key}"
      end
      source = "{% include #{name} #{args.join(' ')} %}"
      # LiquidRenderer caches parsed templates by file name: key them by their source.
      template = site.liquid_renderer.file("(include test) #{source}").parse(source)
      template.render!(payload, registers: { site: site, page: payload["page"] })
    end

    # Runs the block with `site.config` overridden (for example `"baseurl" => "/blog"`).
    def with_config(overrides)
      saved = overrides.keys.to_h { |key| [key, site.config[key]] }
      site.config.merge!(overrides)
      site.filter_cache.clear # `relative_url` and friends memoize per input
      yield
    ensure
      site.config.merge!(saved)
      site.filter_cache.clear
    end

    private

    def stringify(value)
      case value
      when Hash then value.each_with_object({}) { |(k, v), out| out[k.to_s] = stringify(v) }
      when Array then value.map { |v| stringify(v) }
      else value
      end
    end
  end
end
