ENV["RAILS_ENV"] ||= "test"

require "simplecov"
SimpleCov.start "rails"

require File.expand_path("../config/environment", __dir__)
require "rspec/rails"
require "webmock/rspec"
require "slimmer/rspec"
require "gds_api/test_helpers/account_api"
require "gds_api/test_helpers/email_alert_api"

WebMock.disable_net_connect!(allow_localhost: true)

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

GovukTest.configure

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = "random"

  config.before :each do
    rate_limiter = instance_double(Ratelimit, add: nil, exceeded?: false)
    allow(Ratelimit).to receive(:new).and_return(rate_limiter)
  end
end
