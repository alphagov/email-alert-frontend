source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '5.1.3'
gem 'slimmer', '~> 11.0'

gem 'govuk_elements_rails', '~> 3.1'
gem 'govuk_frontend_toolkit', '~> 7.0'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 2.7.2'
gem 'unicorn'

gem 'plek', '~> 2.0'
gem 'govuk_app_config', '~> 0.2.0'
gem 'decent_exposure', '~> 3.0'

gem 'gds-api-adapters', '~> 47.9'
gem 'govuk_navigation_helpers', '~> 6.3'

group :development, :test do
  gem 'pry-byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'cucumber-rails', '~> 1.5', require: false
  gem 'launchy'
  gem 'webmock', '~> 3.0'
  gem 'timecop', '~> 0.9.1'
  gem 'govuk-content-schema-test-helpers', '~> 1.5'
end
