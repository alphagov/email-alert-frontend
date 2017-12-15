source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'decent_exposure', '~> 3.0'
gem 'gds-api-adapters', '~> 50.5'
gem 'govuk_app_config', '~> 0.2.0'
gem 'govuk_elements_rails', '~> 3.1'
gem 'govuk_frontend_toolkit', '~> 7.0'
gem 'govuk_navigation_helpers', '~> 6.3'
gem 'plek', '~> 2.0'
gem 'rails', '5.1.4'
gem 'sass-rails', '~> 5.0'
gem 'slimmer', '~> 11.0'
gem 'uglifier', '>= 2.7.2'
gem 'unicorn'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'govuk-lint'
  gem 'pry-byebug'
end

group :test do
  gem 'cucumber-rails', '~> 1.5', require: false
  gem 'govuk-content-schema-test-helpers', '~> 1.4'
  gem 'launchy'
  gem 'rspec-rails', '~> 3.6'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.0'
end
