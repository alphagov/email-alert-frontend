require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe "subscribing", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic_id) { "GOVUK_123" }
  let(:subscribable_id) { 10 }
  let(:address) { "test@test.com" }

  context "successfully" do
    before do
      email_alert_api_has_subscribable(
        reference: topic_id,
        returned_attributes: {
          id: subscribable_id,
          title: "Test Subscriber List"
        }
      )

      returned_subscription_id = 50
      email_alert_api_creates_a_subscription(
        subscribable_id,
        address,
        returned_subscription_id
      )
    end

    it "subscribes and renders the success page" do
      visit "/email/subscriptions/new?topic_id=#{topic_id}"
      fill_in :address, with: address
      expect(page).to have_content("Test Subscriber List")
      click_button "Subscribe"
      expect(page).to have_content("Subscription created successfully.")
    end
  end
end
