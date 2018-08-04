source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '5.2.0'

gem 'decent_exposure', '~> 3.0'
gem 'jwt', '~> 2.1'
gem 'sass-rails', '~> 5.0'
gem 'slimmer', '~> 13.0'
gem 'uglifier', '~> 4.1'

gem 'gds-api-adapters', '~> 52.7'
gem 'govuk_app_config', '~> 1.7'
gem 'govuk_elements_rails', '~> 3.1'
gem 'govuk_frontend_toolkit', '~> 7.6'
gem 'govuk_publishing_components', '~> 9.9'
gem 'plek', '~> 2.1'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'

  gem 'govuk-lint'
end

group :test do
  gem 'cucumber-rails', '~> 1.6', require: false
  gem 'launchy'
  gem 'phantomjs', '~> 2.1'
  gem 'poltergeist', require: false
  gem 'rspec-rails', '~> 3.8'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.4'

  gem 'govuk-content-schema-test-helpers', '~> 1.6'
end
