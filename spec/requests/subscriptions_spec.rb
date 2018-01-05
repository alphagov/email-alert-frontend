require 'spec_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe "subscriptions", type: :request do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:topic_id) { "GOVUK_123" }
  let(:subscribable_id) { 10 }

  before do
    email_alert_api_has_subscribable(
      reference: topic_id,
      returned_attributes: {
        id: subscribable_id,
        title: "Test Subscriber List",
      }
    )
  end

  describe "GET /new" do
    it "returns a 200" do
      get "/email/subscriptions/new", params: { topic_id: topic_id }
      expect(response.status).to eq(200)
    end

    context "when no topic param is provided" do
      it "returns a 400" do
        get "/email/subscriptions/new", params: {}
        expect(response.status).to eq(400)
      end
    end

    context "when a topic params is provided for something that doesn't exist" do
      before do
        email_alert_api_does_not_have_subscribable(reference: "missing")
      end

      it "returns a 404" do
        get "/email/subscriptions/new", params: { topic_id: "missing" }
        expect(response.status).to eq(404)
      end
    end
  end

  describe "POST create" do
    let(:address) { "test@test.com" }

    before do
      returned_subscription_id = 50
      email_alert_api_creates_a_subscription(
        subscribable_id, address, returned_subscription_id
      )
    end

    it "creates a subscription via email-alert-api" do
      post "/email/subscriptions", params: { topic_id: topic_id, address: address }
      assert_subscribed(subscribable_id, address)
    end

    context "when no address is provided" do
      let(:address) { nil }

      it "shows an error message on the form" do
        post "/email/subscriptions", params: { topic_id: topic_id, address: address }

        expect(response.status).to eq(200)
        expect(response.body).to include("Please enter a valid email address")
      end
    end
  end
end
