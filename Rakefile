# frozen_string_literal: true

require "rake/testtask"

desc "Run the Ruby tests: _includes/ (Minitest, real Jekyll/Liquid rendering) and bin/check-content"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/{includes,bin}/**/*_test.rb"
end

task default: :test
