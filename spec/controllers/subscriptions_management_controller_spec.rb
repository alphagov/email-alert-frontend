require 'rails_helper'

RSpec.describe SubscriptionsManagementController do
  EMAIL_ALERT_API_ENDPOINT = Plek.find("email-alert-api")
  let(:subscriber_id) { 1 }
  let(:subscriber_address) { "test@example.com" }
  let(:subscription_id) { SecureRandom.uuid }
  let(:new_frequency) { "weekly" }
  let(:new_address) { "test2@example.com" }
  let(:session_data) do
    {
      "authentication": {
        "subscriber_id": subscriber_id,
        "redirect": "/email/manage"
      }
    }.with_indifferent_access
  end

  render_views

  before do
    stub_request(:get, EMAIL_ALERT_API_ENDPOINT + "/subscribers/#{subscriber_id}/subscriptions")
      .to_return(
        status: 200,
        body: {
          "subscriber" => {
            "id" => subscriber_id,
            "address" => subscriber_address
          },
          "subscriptions" => [
            {
              "subscriber_id" => 1,
              "subscriber_list_id" => 1000,
              "frequency" => "daily",
              "id" => subscription_id,
              "subscriber_list" => {
                "id" => 1000,
                "slug" => "some-thing",
                "title" => "Some thing"
              }
            }
          ]
        }.to_json
      )

    stub_request(:patch, EMAIL_ALERT_API_ENDPOINT + "/subscriptions/#{subscription_id}")
      .to_return(
        status: 200,
        body: {
          "subscription" => {
            "subscriber_id" => 1,
            "subscriber_list_id" => 1000,
            "frequency" => "weekly",
            "id" => subscription_id,
            "subscriber_list" => {
              "id" => 1000,
              "slug" => "some-thing",
              "title" => "Some thing"
            }
          }
        }.to_json
      )

    stub_request(:patch, EMAIL_ALERT_API_ENDPOINT + "/subscribers/#{subscriber_id}")
      .to_return(
        status: 200,
        body: {
          "subscriber" => {
            "id" => subscriber_id,
            "address" => subscriber_address
          }
        }.to_json
      )

    stub_request(:delete, EMAIL_ALERT_API_ENDPOINT + "/subscribers/#{subscriber_id}")
      .to_return(status: 200)
  end

  describe "GET /email/manage" do
    context "when the page is requested" do
      it "returns 200" do
        get :index, session: session_data
        expect(response).to have_http_status(:ok)
      end

      it "sets the Cache-Control header to 'private, no-cache'" do
        get :index, session: session_data
        expect(response.headers["Cache-Control"]).to eq("private, no-cache")
      end
    end

    context "when there is a subscriber with a subscription" do
      it "renders the subscriber's email address" do
        get :index, session: session_data
        expect(response.body).to include("Subscriptions for #{subscriber_address}")
      end

      it "renders the subscriber's subscriptions" do
        get :index, session: session_data
        expect(response.body).to include("Some thing")
      end
    end

    context "when there is a subscriber without any subscription" do
      let(:subscriber_id_with_no_subscriptions) { 2 }
      let(:subscriber_address_with_no_subscriptions) { "nothing@example.com" }
      let(:session_data_with_no_subscriptions) do
        {
          "authentication": {
            "subscriber_id": subscriber_id_with_no_subscriptions,
            "redirect": "/email/manage"
          }
        }.with_indifferent_access
      end

      before do
        stub_request(:get, EMAIL_ALERT_API_ENDPOINT + "/subscribers/#{subscriber_id_with_no_subscriptions}/subscriptions")
          .to_return(
            status: 200,
            body: {
              "subscriber" => {
                "id" => subscriber_id_with_no_subscriptions,
                "address" => subscriber_address_with_no_subscriptions
              },
              "subscriptions" => []
            }.to_json
          )
      end

      it "renders the subscriber's email address" do
        get :index, session: session_data_with_no_subscriptions
        expect(response.body).to include("Subscriptions for #{subscriber_address_with_no_subscriptions}")
      end

      it "renders a message" do
        get :index, session: session_data_with_no_subscriptions
        expect(response.body).to include("You aren’t subscribed to any topics on GOV.UK.")
      end
    end
  end

  describe "GET /email/manage/frequency/:id" do
    context "when the page is requested" do
      it "returns 200" do
        get :update_frequency, params: { id: subscription_id }, session: session_data
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the requested subscription exists" do
      it "renders a form" do
        get :update_frequency, params: { id: subscription_id }, session: session_data
        expect(response.body).to include(%(action="/email/manage/frequency/#{subscription_id}/change"))
      end
    end

    context "when the requested subscription doesn't exist" do
      let(:non_existant_subscription_id) { SecureRandom.uuid }

      it "returns 404" do
        get :update_frequency, params: { id: non_existant_subscription_id }, session: session_data
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /email/manage/frequency/:id/change" do
    context "when no frequency is provided" do
      it "raises an exception" do
        expect {
          post :change_frequency, params: { id: subscription_id }, session: session_data
        }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when an invalid frequency is provided" do
      let(:new_frequency) { "foobar" }

      it "redirects to the subscription management page" do
        post :change_frequency, params: { id: subscription_id, new_frequency: new_frequency }, session: session_data
        expect(response).to redirect_to(list_subscriptions_path)
      end
    end

    context "when a valid frequency is provided" do
      it "redirects to the subscription management page" do
        post :change_frequency, params: { id: subscription_id, new_frequency: new_frequency }, session: session_data
        expect(response).to redirect_to(list_subscriptions_path)
      end
    end
  end

  describe "GET /email/manage/address" do
    context "when the page is requested" do
      it "returns 200" do
        get :update_address, session: session_data
        expect(response).to have_http_status(:ok)
      end

      it "renders a form" do
        get :update_address, session: session_data
        expect(response.body).to include(%(action="/email/manage/address/change"))
      end
    end
  end

  describe "POST /email/manage/address/change" do
    context "when no email address is provided" do
      let(:new_address) { "" }

      it "renders an error message" do
        post :change_address, params: { new_address: new_address }, session: session_data
        expect(response.body).to include(SubscriptionsManagementController::MISSING_EMAIL_ERROR)
      end

      it "renders a form" do
        post :change_address, params: { new_address: new_address }, session: session_data
        expect(response.body).to include(%(action="/email/manage/address/change"))
      end
    end

    context "when an invalid address is provided" do
      let(:new_address) { "foobar" }

      before do
        stub_request(:patch, EMAIL_ALERT_API_ENDPOINT + "/subscribers/#{subscriber_id}")
          .to_return(status: 422)
      end

      it "renders an error message" do
        post :change_address, params: { new_address: new_address }, session: session_data
        expect(response.body).to include(SubscriptionsManagementController::INVALID_EMAIL_ERROR)
      end

      it "renders a form" do
        post :change_address, params: { new_address: new_address }, session: session_data
        expect(response.body).to include(%(action="/email/manage/address/change"))
      end
    end

    context "when a valid address is provided" do
      it "redirects to the subscription management page" do
        post :change_address, params: { new_address: new_address }, session: session_data
        expect(response).to redirect_to(list_subscriptions_path)
      end
    end
  end

  describe "GET /email/manage/unsubscribe-all" do
    context "when the page is requested" do
      it "returns 200" do
        get :confirm_unsubscribe_all, session: session_data
        expect(response).to have_http_status(:ok)
      end

      it "renders a message" do
        get :confirm_unsubscribe_all, session: session_data
        expect(response.body).to include("You won’t get any more automated emails from GOV.UK.")
      end
    end

    it "renders a form" do
      get :confirm_unsubscribe_all, session: session_data
      expect(response.body).to include(%(action="/email/manage/unsubscribe-all"))
    end
  end

  describe "POST /email/manage/unsubscribe-all" do
    context "when the subscriber is unsubscribed" do
      it "redirects to subscription management" do
        post :confirmed_unsubscribe_all, session: session_data
        expect(response).to redirect_to(list_subscriptions_path)
      end

      it "sets a flash about the success" do
        post :confirmed_unsubscribe_all, session: session_data
        expect(flash[:success]).to match(/unsubscribed from all your subscriptions/)
      end
    end
  end
end
