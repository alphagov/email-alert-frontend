source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "6.0.2.2"

gem "gds-api-adapters", "~> 63.5"
gem "govuk_app_config", "~> 2.1"
gem "govuk_publishing_components", "~> 21.32.0"
gem "jwt", "~> 2.2"
gem "plek", "~> 3.0"
gem "sass-rails", "~> 5.0"
gem "slimmer", "~> 13.2"
gem "uglifier", "~> 4.2"

group :development, :test do
  gem "pry-byebug"
  gem "rubocop-govuk"
end

group :test do
  gem "capybara", "~> 3.31"
  gem "govuk_schemas"
  gem "rspec-rails", "~> 3.9"
  gem "timecop", "~> 0.9.1"
  gem "webmock", "~> 3.8"
end
