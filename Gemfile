source "https://rubygems.org"

gem "jekyll", "~> 4.4.0"
gem "no-style-please"

# No longer default gems since Ruby 3.4, but Jekyll still needs them.
gem "csv"
gem "logger"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.17"
  gem "jekyll-sitemap", "~> 1.4"
end

# Tests (see test/ and the Rakefile). minitest stays on 5.x: 6.x pulls in extra native gems (prism).
group :test do
  gem "minitest", "~> 6.0"
  gem "rake"
end
