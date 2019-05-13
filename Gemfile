source 'https://rubygems.org'

ruby File.read(".ruby-version").strip

gem 'rails', '5.2.3'

gem 'decent_exposure', '~> 3.0'
gem 'jwt', '~> 2.1'
gem 'sass-rails', '~> 5.0'
gem 'slimmer', '~> 13.0'
gem 'uglifier', '~> 4.1'

gem 'gds-api-adapters', '~> 59.2'
gem 'govuk_app_config', '~> 1.16'
gem 'govuk_publishing_components', '~> 16.16'
gem 'plek', '~> 2.1'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-byebug'

  gem 'govuk-lint'
end

group :test do
  gem 'cucumber-rails', '~> 1.7', require: false
  gem 'govuk_schemas'
  gem 'launchy'
  gem 'phantomjs', '~> 2.1'
  gem 'rspec-rails', '~> 3.8'
  gem 'timecop', '~> 0.9.1'
  gem 'webmock', '~> 3.4'
end
