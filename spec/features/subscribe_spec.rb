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

      # We submit the form with JavaScript because the component doesn't render
      # in the test environment, it looks like this:
      #
      # <test-govuk-component data-template="govuk_component-button">{"text":"Subscribe","margin_bottom":true}</test-govuk-component>
      page.execute_script("document.querySelector('form').submit()")
      expect(page).to have_content("Subscribed successfully")
    end

    it "lets the user go back" do
      page.driver.add_header("Referer", "http://example.com", permanent: false)

      visit "/email/subscriptions/new?topic_id=#{topic_id}"
      expect(back_link_href).to eq("http://example.com/")

      fill_in :address, with: address
      page.execute_script("document.querySelector('form').submit()")
      expect(page).to have_content("Subscribed successfully")

      expect(back_link_href).to include(
        "/email/subscriptions/new?topic_id=GOVUK_123"
      )

      click_link "Back"

      # The referer points back to the confirmation page, which probably isn't
      # helpful if they're on the form, so fallback to somewhere sensible.
      expect(back_link_href).to eq("https://www.gov.uk/")
    end
  end

  def back_link_href
    page.find("a", text: "Back")[:href]
  end
end
