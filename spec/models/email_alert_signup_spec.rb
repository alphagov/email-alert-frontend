require "spec_helper"
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSignup do
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::EmailAlertApi

  let(:base_url)      { "http://some-domain" }
  let(:api_client)    { GdsApi::EmailAlertApi.new(base_url) }

  let(:signup_page) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('email_alert_signup').except('govdelivery_title').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  let(:signup_page_with_govdelivery_title) {
    dummy_http_response = double("net http response",
      code: 200,
      body: govuk_content_schema_example('email_alert_signup').to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_ostruct
  }

  before do
    EmailAlertFrontend.register_service(:email_alert_api, api_client)
  end

  it "is invalid with no signup page" do
    expect(EmailAlertSignup.new(nil)).not_to be_valid
  end

  it "does not attempt to create a subscription if no signup page is provided" do
    expect(api_client).not_to receive(:find_or_create_subscriber_list)

    expect(EmailAlertSignup.new(nil).save).to eq(false)
  end

  describe "#save" do
    it "sends the correct subscription params to the email alert api" do
      expect(api_client).to receive(:find_or_create_subscriber_list)
        .with(
          {
           "title" => "Employment policy",
           "tags"  => {"policies"=>["employment"]},
           "links" => {"policies"=>["f8c3682c-3a88-4f35-afba-3607384e39e6"]}
          }
        )
        .and_return(double(subscriber_list: double(subscription_url: 'http://foo')))

      email_signup = EmailAlertSignup.new(signup_page)
      email_signup.save
    end
  end

  describe "#subscription_url" do
    it "is the subscription_url returned by the API" do
      expect(api_client).to receive(:find_or_create_subscriber_list)
        .with(
          {
           "title" => "Employment policy",
           "tags"  => {"policies"=>["employment"]},
           "links" => {"policies"=>["f8c3682c-3a88-4f35-afba-3607384e39e6"]}
          }
        )
        .and_return(double(subscriber_list: double(subscription_url: 'http://foo')))

      email_signup = EmailAlertSignup.new(signup_page)
      email_signup.save

      expect("http://foo").to eq(email_signup.subscription_url)
    end
  end

  describe "#breadcrumbs" do
    it "returns a nested hash of the breadcrumbs" do
      email_signup = EmailAlertSignup.new(signup_page)
      expected_breadcrumbs = {
        title: "Employment",
        link: "https://www.gov.uk/government/policies/employment",
      }

      expect(email_signup.breadcrumbs).to eq(expected_breadcrumbs)
    end
  end
end
