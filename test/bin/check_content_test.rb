# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "open3"
require "tmpdir"

# Runs bin/check-content against a scratch fixture site (CHECK_CONTENT_ROOT), one rule per test.
# The fixture has the real taxonomy and a minimal _config.yml; each test writes the documents it needs.
class CheckContentTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  SCRIPT = File.join(ROOT, "bin", "check-content")

  FRONT = <<~YAML
    layout: post
    title: "A title"
    date: 2026-01-10 10:00:00
    categories: ["Mathematics"]
    description: "A description."
  YAML

  def setup
    @site = Dir.mktmpdir("check-content")
    FileUtils.mkdir_p(File.join(@site, "_data"))
    FileUtils.cp(File.join(ROOT, "_data", "taxonomy.yml"), File.join(@site, "_data"))
    File.write(File.join(@site, "_config.yml"), "title: Test\n")
  end

  def teardown
    FileUtils.rm_rf(@site)
  end

  def write(path, body, front: FRONT)
    full = File.join(@site, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.write(full, "---\n#{front}---\n#{body}")
  end

  def check
    output, status = Open3.capture2e({ "CHECK_CONTENT_ROOT" => @site }, "ruby", SCRIPT)
    [status.exitstatus, output]
  end

  def lines(output, kind)
    output.lines.grep(/\A#{kind}:/).map(&:strip)
  end

  def test_a_valid_document_passes_without_warnings
    write("_posts/math/2026-01-10-ok.md", "## Section\n\nText.\n")

    status, output = check
    assert_equal 0, status, output
    assert_empty lines(output, "warning")
  end

  def test_missing_date_and_categories_are_errors
    write("_posts/math/2026-01-10-bad.md", "x\n", front: "title: \"Bad\"\n")

    status, output = check
    assert_equal 1, status
    assert_includes output, "missing date"
    assert_includes output, "missing categories"
  end

  def test_category_outside_the_taxonomy_is_an_error
    write("_posts/math/2026-01-10-cat.md", "x\n", front: FRONT.sub("Mathematics", "Maths"))

    status, output = check
    assert_equal 1, status
    assert(lines(output, "error").any? { |l| l.include?("Maths") }, output)
  end

  def test_upper_case_file_name_is_an_error
    write("_posts/math/2026-01-10-Upper.md", "x\n")

    status, output = check
    assert_equal 1, status
    assert_includes output, "must be lowercase"
  end

  def test_level_one_heading_in_the_body_warns
    write("_posts/math/2026-01-10-h1.md", "# Title again\n")

    assert_includes check.last, "level-1 heading in the body"
  end

  def test_level_one_heading_inside_a_code_block_is_ignored
    write("_posts/math/2026-01-10-code.md", "```sh\n# a shell comment\n```\n")

    refute_includes check.last, "level-1 heading"
  end

  def test_skipped_heading_level_warns_once
    write("_posts/math/2026-01-10-skip.md", "## A\n\n#### B\n\n#### C\n")

    warnings = lines(check.last, "warning").grep(/skips/)
    assert_equal 1, warnings.size
    assert_includes warnings.first, "heading \"B\" skips from h2 to h4"
  end

  def test_starting_at_h3_counts_as_a_skip
    write("_posts/math/2026-01-10-h3.md", "### Starts low\n")

    assert_includes check.last, "skips from h1 to h3"
  end

  def test_pt_br_notice_without_lang_warns
    notice = %({% include warning.html title="About the language" text="This document is in pt-br, there's no translation to english." %}\n)
    write("_annotations/c/2026-01-10-pt.md", notice)

    assert_includes check.last, "pt-BR language notice but no `lang: pt-BR`"
  end

  def test_pt_br_notice_with_lang_passes
    notice = %({% include warning.html title="About the language" text="This document is in pt-br, there's no translation to english." %}\n)
    write("_annotations/c/2026-01-10-pt.md", notice, front: "#{FRONT}lang: pt-BR\n")

    refute_includes check.last, "lang: pt-BR"
  end

  def test_image_without_alt_warns
    write("_posts/math/2026-01-10-img.md", %(<img src="/x.png">\n))

    assert_includes check.last, "<img> without alt text"
  end

  def test_underlined_heading_warns
    write("_posts/math/2026-01-10-setext.md", "Intro.\n\nSection\n=======\n\nText.\n")

    assert_includes check.last, "underlined (=== / ---) heading"
  end

  def test_horizontal_rule_is_not_a_heading
    write("_posts/math/2026-01-10-hr.md", "Intro.\n\n---\n\nText.\n")

    refute_includes check.last, "underlined"
  end

  def test_post_without_description_warns
    write("_posts/math/2026-01-10-nodesc.md", "Text.\n", front: FRONT.sub(/^description:.*\n/, ""))

    assert_includes check.last, "no `description`"
  end

  def test_annotation_without_description_does_not_warn
    write("_annotations/c/2026-01-10-note.md", "Text.\n", front: FRONT.sub(/^description:.*\n/, ""))

    refute_includes check.last, "no `description`"
  end
end
