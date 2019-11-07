source "https://rubygems.org"

ruby File.read(".ruby-version").strip

gem "rails", "5.2.3"

gem "decent_exposure", "~> 3.0"
gem "gds-api-adapters", "~> 61.0"
gem "govuk_app_config", "~> 2.0"
gem "govuk_publishing_components", "~> 21.9.0"
gem "jwt", "~> 2.2"
gem "plek", "~> 3.0"
gem "sass-rails", "~> 5.0"
gem "slimmer", "~> 13.0"
gem "uglifier", "~> 4.2"

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "govuk-lint"
  gem "pry-byebug"
end

group :test do
  gem "cucumber-rails", "~> 2.0", require: false
  gem "govuk_schemas"
  gem "launchy"
  gem "rspec-rails", "~> 3.9"
  gem "timecop", "~> 0.9.1"
  gem "webmock", "~> 3.7"
end
