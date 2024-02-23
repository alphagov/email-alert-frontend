source "https://rubygems.org"

ruby "~> 3.2.0"

gem "rails", "7.1.3"

gem "bootsnap", require: false
gem "dartsass-rails"
gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_personalisation"
gem "govuk_publishing_components", git: "https://github.com/alphagov/govuk_publishing_components.git", branch: "spike-font-size-changes-2"
gem "jwt"
gem "plek"
gem "ratelimit"
gem "slimmer"
gem "sprockets-rails"
gem "uglifier"

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
