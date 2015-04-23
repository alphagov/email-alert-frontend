require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSignup do
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::EmailAlertApi

  let(:base_url)      { "http://some-domain" }
  let(:api_client)    { GdsApi::EmailAlertApi.new(base_url) }

  let(:content_item) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('email_alert_signup').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let (:subscription_params) {
    {
      "title" => "Employment",
      "tags" => {
        "policy" => ["employment"]
      },
      "subscription_url" => "http://govdelivery_signup_url"
    }
  }

  let (:create_subscriber_list_request) {
    email_alert_api_creates_subscriber_list(subscription_params)
  }

  before do
    EmailAlertFrontend.register_service(:email_alert_api, api_client)
  end

  it "is invalid with no content item" do
    expect(EmailAlertSignup.new(nil)).not_to be_valid
  end

  describe "#save" do
    it "creates the topic in GovDelivery using the tag and title" do
      email_alert_api_does_not_have_subscriber_list(subscription_params)
      create_subscriber_list_request = email_alert_api_creates_subscriber_list(subscription_params)
      email_signup = EmailAlertSignup.new(content_item)


      expect email_signup.save
      expect(create_subscriber_list_request).to have_been_requested
    end

    it "does not create a subscription if the subtopic is missing" do
      expect(api_client).not_to receive(:find_or_create_subscriber_list)

      expect(EmailAlertSignup.new(nil).save).to eq(false)
    end
  end

  describe "#subscription_url" do
    it "is the subscription_url returned by the API" do
      email_alert_api_has_subscriber_list(subscription_params)

      email_signup = EmailAlertSignup.new(content_item)
      email_signup.save

      expect("http://govdelivery_signup_url").to eq(email_signup.subscription_url)
    end
  end

  describe "#breadcrumbs" do
    it "returns a nested hash of the breadcrumbs" do
      email_signup = EmailAlertSignup.new(content_item)

      expected_breadcrumbs = {
        title: "Employment",
        link: "https://www.gov.uk/government/policies/employment",
      }

      expect(email_signup.breadcrumbs).to eq(expected_breadcrumbs)
    end
  end
end
