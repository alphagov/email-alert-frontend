source "https://rubygems.org"

ruby "~> 3.3.1"

gem "rails", "8.0.2"

gem "bootsnap", require: false
gem "dartsass-rails"
gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_personalisation"
gem "govuk_publishing_components",  git: "https://github.com/alphagov/govuk_publishing_components.git", branch: "test-upgrade-service-header"
gem "govuk_web_banners"
gem "jwt"
gem "plek"
gem "ratelimit"
gem "sprockets-rails"
gem "terser"

group :development, :test do
  gem "climate_control"
  gem "govuk_test"
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop-govuk"
end

group :test do
  gem "capybara"
  gem "govuk_schemas"
  gem "simplecov"
  gem "timecop"
  gem "webmock"
end
