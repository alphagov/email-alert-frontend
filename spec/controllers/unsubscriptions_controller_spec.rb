require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe UnsubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi

  render_views

  let(:uuid) { "A-UUID" }
  let(:title) { "A title" }

  before do
    email_alert_api_unsubscribes_a_subscription(uuid)
  end

  describe "GET /email/unsubscribe/:uuid" do
    it "responds with a 200" do
      get :confirm, params: { uuid: uuid, title: title }

      expect(response.status).to eq(200)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      get :confirm, params: { uuid: uuid, title: title }

      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    it "renders a form" do
      get :confirm, params: { uuid: uuid, title: title }

      expect(response.body).to include(%(action="/email/unsubscribe/#{uuid}"))
    end

    it "renders the title on the page" do
      get :confirm, params: { uuid: uuid, title: title }

      expect(response.body).to include("You won’t get any more updates about #{title}")
    end

    it "passes the title through to the 'confirmed' action" do
      get :confirm, params: { uuid: uuid, title: title }

      expect(response.body).to include(%(value="#{title}"))
    end

    context "when no title is provided" do
      it "shows a different message" do
        get :confirm, params: { uuid: uuid }

        expect(response.body).to include("You won’t get any more updates about this topic.")
      end
    end

    context "when a blank title is provided" do
      it "shows a different message" do
        get :confirm, params: { uuid: uuid, title: " " }

        expect(response.body).to include("You won’t get any more updates about this topic.")
      end
    end
  end

  describe "POST /email/unsubscribe/:uuid" do
    it "responds with a 200" do
      post :confirmed, params: { uuid: uuid, title: title }

      expect(response.status).to eq(200)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      post :confirmed, params: { uuid: uuid, title: title }

      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    it "renders a confirmation page" do
      post :confirmed, params: { uuid: uuid, title: title }

      expect(response.body).to include("You won’t get any more updates about #{title}")
    end

    it "sends an unsubscribe request to email-alert-api" do
      post :confirmed, params: { uuid: uuid, title: title }

      assert_unsubscribed(uuid)
    end

    context "when the user has already unsubscribed" do
      before do
        email_alert_api_has_no_subscription_for_uuid(uuid)
      end

      it "renders the same confirmation page" do
        post :confirmed, params: { uuid: uuid, title: title }

        expect(response.body).to include("You won’t get any more updates about #{title}")
      end
    end

    context "when no title is provided" do
      it "shows a different message" do
        post :confirmed, params: { uuid: uuid }

        expect(response.body).to include("You won’t get any more updates about this topic.")
      end
    end

    context "when a blank title is provided" do
      it "shows a different message" do
        post :confirmed, params: { uuid: uuid, title: " " }

        expect(response.body).to include("You won’t get any more updates about this topic.")
      end
    end
  end
end
