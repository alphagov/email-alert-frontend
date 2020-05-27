source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "6.0.3.1"

gem "gds-api-adapters", "~> 63.6"
gem "govuk_app_config", "~> 2.2"
gem "govuk_publishing_components", "~> 21.53.0"
gem "jwt", "~> 2.2"
gem "plek", "~> 3.0"
gem "sass-rails", "~> 5.0"
gem "slimmer", "~> 14.0.0"
gem "uglifier", "~> 4.2"

group :development, :test do
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0"
  gem "rubocop-govuk"
end

group :test do
  gem "capybara", "~> 3.32"
  gem "govuk_schemas"
  gem "timecop", "~> 0.9.1"
  gem "webmock", "~> 3.8"
end
