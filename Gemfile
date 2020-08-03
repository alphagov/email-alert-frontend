source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "6.0.3.2"

gem "gds-api-adapters", "~> 67.0"
gem "govuk_app_config", "~> 2.2"
gem "govuk_publishing_components", "~> 21.60.1"
gem "jwt", "~> 2.2"
gem "plek", "~> 4.0"
gem "ratelimit"
gem "sass-rails", "~> 5.0"
gem "slimmer", "~> 15.0.0"
gem "uglifier", "~> 4.2"

group :development, :test do
  gem "govuk_test", "~> 1.0"
  gem "jasmine", "~> 3.6.0"
  gem "jasmine_selenium_runner", "~> 3"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0"
  gem "rubocop-govuk"
end

group :test do
  gem "capybara", "~> 3.33"
  gem "govuk_schemas"
  gem "timecop", "~> 0.9.1"
  gem "webmock", "~> 3.8"
end
