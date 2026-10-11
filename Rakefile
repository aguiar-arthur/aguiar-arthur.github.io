# frozen_string_literal: true

require "rake/testtask"

desc "Run the Ruby tests of _includes/ (Minitest, real Jekyll/Liquid rendering)"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/includes/**/*_test.rb"
end

namespace :test do
  desc "Run the JavaScript tests of assets/js (node:test + jsdom; run `npm ci` once)"
  task :js do
    sh "npm", "test"
  end

  desc "Run the Ruby and the JavaScript tests"
  task all: %i[test js]
end

task default: :test
