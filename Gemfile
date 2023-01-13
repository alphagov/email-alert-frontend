source "https://rubygems.org"
ruby File.read(".ruby-version")

gem "rails", "7.0.4"

gem "bootsnap", require: false
gem "gds-api-adapters"
gem "govuk_app_config"
gem "govuk_personalisation"
gem "govuk_publishing_components"
gem "jwt"
gem "mail", "~> 2.7.1"  # TODO: remove once https://github.com/mikel/mail/issues/1489 is fixed.
gem "plek"
gem "ratelimit"
gem "sassc-rails"
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
