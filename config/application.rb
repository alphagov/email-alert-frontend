require_relative "boot"

# require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"
require "sprockets/railtie"
require "govuk_publishing_components/middleware/ga4_optimise"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EmailAlertFrontend
  class Application < Rails::Application
    include GovukPublishingComponents::AppHelpers::AssetHelper

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Add lib directory to autoload paths
    config.autoload_paths += Dir[Rails.root.join("lib")]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Path within public/ where assets are compiled to
    config.assets.prefix = "/assets/email-alert-frontend"

    # Using a sass css compressor causes a scss file to be processed twice
    # (once to build, once to compress) which breaks the usage of "unquote"
    # to use CSS that has same function names as SCSS such as max.
    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil

    # Use the middleware to compact data-ga4-event/link attributes
    config.middleware.use GovukPublishingComponents::Middleware::Ga4Optimise
  end
end
