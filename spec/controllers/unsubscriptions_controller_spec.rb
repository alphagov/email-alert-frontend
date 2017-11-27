require 'rails_helper'
require 'gds_api/test_helpers/email_alert_api'

RSpec.describe UnsubscriptionsController do
  render_views
  include GdsApi::TestHelpers::EmailAlertApi

  describe "showing a confirm form" do
    it "responds with a 200" do
      get :confirm, params: { uuid: "A-UUID", title: "A title" }

      expect(response.status).to eq(200)
    end

    it "renders a form" do
      get :confirm, params: { uuid: "A-UUID", title: "A title" }

      expect(response.body).to include('action="/email/unsubscribe/A-UUID"')
    end

    it "renders the title on the page" do
      get :confirm, params: { uuid: "A-UUID", title: "A title" }

      expect(response.body).to include("You are unsubscribing from A title")
    end

    context "when no title is provided" do
      it "shows a different message" do
        get :confirm, params: { uuid: "A-UUID" }

        expect(response.body).to include("Confirm your unsubscription")
      end
    end
  end
end
