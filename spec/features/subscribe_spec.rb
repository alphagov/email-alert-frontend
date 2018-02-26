require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe "subscribing", type: :feature do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic_id) { "GOVUK_123" }
  let(:subscribable_id) { 10 }
  let(:address) { "test@test.com" }
  let(:frequency) { "weekly" }

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
      frequency,
      returned_subscription_id
    )
  end

  feature "signing up a for a subscription" do
    it "subscribes and renders the success page" do
      visit "/email/subscriptions/new?topic_id=#{topic_id}"

      expect(page).to have_content("How often do you want to get updates?")
      choose "frequency", option: frequency, visible: false
      submit_form

      expect(page).to have_content("What’s your email address?")
      fill_in :address, with: address
      submit_form

      expect(page).to have_content("You’ve subscribed successfully")
      expect(page).to have_content("Test Subscriber List")
    end
  end

  feature "back link navigation" do
    let(:new_subscription_path) { "/email/subscriptions/new?topic_id=#{topic_id}" }
    let(:new_subscription_path_regex) do
      Regexp.new(
        Regexp.escape(new_subscription_path)
      )
    end

    context "arrived at form with referer" do
      it "has a link to the referer forced onto the gov.uk domain" do
        page.driver.add_header("Referer", "http://example.com/some/page?query=string", permanent: false)
        visit new_subscription_path
        expect(back_link_href).to match(%r{gov.uk/some/page\?query=string$})
      end
    end

    context "arrived at form without referer" do
      it "links to govuk website root" do
        visit new_subscription_path
        page.save_screenshot('screenshot.png')
        expect(back_link_href).to match(%r{gov.uk/$})
      end
    end

    context "on address page" do
      it "links to the first part of the form" do
        visit "/email/subscriptions/new?topic_id=#{topic_id}&frequency=#{frequency}"
        expect(back_link_href).to match(new_subscription_path_regex)
      end
    end

    context "on complete page" do
      it "links to the first part of the form" do
        visit "/email/subscriptions/complete?topic_id=#{topic_id}&frequency=#{frequency}"
        expect(back_link_href).to match(new_subscription_path_regex)
      end
    end
  end

  def submit_form
    # We submit the form with JavaScript because the component doesn't render
    # in the test environment, it looks like this:
    #
    # <test-govuk-component data-template="govuk_component-button">{"text":"Subscribe","margin_bottom":true}</test-govuk-component>
    page.execute_script("document.querySelector('form').submit()")
  end

  def back_link_href
    page.find("a", text: "Back")[:href]
  end
end
