source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "6.0.3.2"

gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_publishing_components"
gem "jwt"
gem "plek"
gem "ratelimit"
gem "sass-rails"
gem "slimmer"
gem "uglifier"

group :development, :test do
  gem "govuk_test"
  gem "jasmine"
  gem "jasmine_selenium_runner"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
end

group :test do
  gem "capybara"
  gem "govuk_schemas"
  gem "timecop"
  gem "webmock"
end
