require 'spec_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe "subscriptions", type: :request do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "POST create" do
    it "creates a subscription via email-alert-api" do
      subscribable_id = "5"
      address = "test@test.com"
      returned_subscription_id = 10
      email_alert_api_creates_a_subscription(
        subscribable_id, address, returned_subscription_id
      )

      post "/email/subscriptions", params: { subscribable_id: 5, address: "test@test.com" }
      assert_subscribed(subscribable_id, address)
    end
  end
end
