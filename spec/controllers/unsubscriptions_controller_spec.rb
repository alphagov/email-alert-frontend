require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe UnsubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi

  render_views

  let(:id) { "A-UUID" }
  let(:title) { "title" }

  before do
    email_alert_api_has_subscription(id, "immediately", title: title)
    email_alert_api_unsubscribes_a_subscription(id)
  end

  describe "GET /email/unsubscribe/:id" do
    it "responds with a 200" do
      get :confirm, params: { id: id }

      expect(response.status).to eq(200)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      get :confirm, params: { id: id }

      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    it "renders a form" do
      get :confirm, params: { id: id }

      expect(response.body).to include(%(action="/email/unsubscribe/#{id}"))
    end

    it "renders the title on the page" do
      get :confirm, params: { id: id }

      expect(response.body).to include("You won’t get any more updates about #{title}")
    end

    it "passes the title through to the 'confirmed' action" do
      get :confirm, params: { id: id }

      expect(response.body).to include(%(value="#{title}"))
    end
  end

  describe "POST /email/unsubscribe/:id" do
    it "responds with a 200" do
      post :confirmed, params: { id: id }

      expect(response.status).to eq(200)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      post :confirmed, params: { id: id }

      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    it "renders a confirmation page" do
      post :confirmed, params: { id: id }

      expect(response.body).to include("You won’t get any more updates about #{title}")
    end

    it "sends an unsubscribe request to email-alert-api" do
      post :confirmed, params: { id: id }

      assert_unsubscribed(id)
    end

    context "when the user has already unsubscribed" do
      before do
        email_alert_api_has_no_subscription_for_uuid(id)
      end

      it "renders the same confirmation page" do
        post :confirmed, params: { id: id }

        expect(response.body).to include("You won’t get any more updates about #{title}")
      end
    end
  end
end
