source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '5.1.5'

gem 'decent_exposure', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'slimmer', '~> 12.0'
gem 'uglifier', '~> 4.1'

gem 'gds-api-adapters', '~> 51.3'
gem 'govuk_app_config', '~> 1.3'
gem 'govuk_elements_rails', '~> 3.1'
gem 'govuk_frontend_toolkit', '~> 7.4'
gem 'govuk_navigation_helpers', '~> 9.0'
gem 'govuk_publishing_components', '~> 5.2'
gem 'plek', '~> 2.1'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'

  gem 'govuk-lint'
end

group :test do
  gem 'cucumber-rails', '~> 1.5', require: false
  gem 'launchy'
  gem 'phantomjs', '~> 2.1'
  gem 'poltergeist', require: false
  gem 'rspec-rails', '~> 3.6'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.3'

  gem 'govuk-content-schema-test-helpers', '~> 1.6'
end
