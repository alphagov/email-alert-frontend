RSpec.describe UnsubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi

  render_views

  let(:id) { SecureRandom.uuid }
  let(:subscriber_id) { 1 }
  let(:title) { "title" }

  before do
    stub_email_alert_api_has_subscription(
      id, "immediately", title: title, subscriber_id: subscriber_id
    )
    stub_email_alert_api_unsubscribes_a_subscription(id)
  end

  describe "GET /email/unsubscribe/:id" do
    it "responds with a 200" do
      get :confirm, params: { id: id }
      expect(response).to have_http_status(:ok)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      get :confirm, params: { id: id }
      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    context "when the subscription has already ended" do
      before do
        stub_email_alert_api_has_subscription(
          id, "immediately", ended: true, title: "VAT Rates"
        )
      end

      it "show a message saying subscription has ended" do
        get :confirm, params: { id: id }
        expect(response.body).to include("You’ve already unsubscribed from VAT Rates")
      end
    end

    context "when the user has modified their subscription" do
      let(:original_subscription_id) { SecureRandom.uuid }
      let(:latest_subscription_id) { SecureRandom.uuid }

      before do
        stub_email_alert_api_has_subscriptions([
          {
            id: original_subscription_id,
            frequency: "immediately",
            ended: true,
          },
          {
            id: latest_subscription_id,
            frequency: "immediately",
            ended: false,
          },
        ])
      end

      it "redirects to the latest subscription" do
        get :confirm, params: { id: original_subscription_id }
        expect(response).to redirect_to(confirm_unsubscribe_path(latest_subscription_id))
      end
    end
  end

  describe "POST /email/unsubscribe/:id" do
    it "responds with a 200" do
      post :confirmed, params: { id: id }
      expect(response).to have_http_status(:ok)
    end

    it "sets the Cache-Control header to 'private, no-cache'" do
      post :confirmed, params: { id: id }
      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end

    it "renders a confirmation page" do
      post :confirmed, params: { id: id }

      expect(response.body).to include(
        I18n.t!("unsubscriptions.confirmation.with_title", title: title),
      )
    end

    it "sends an unsubscribe request to email-alert-api" do
      post :confirmed, params: { id: id }
      assert_unsubscribed(id)
    end

    context "when the user has already unsubscribed" do
      before do
        stub_email_alert_api_has_no_subscription_for_uuid(id)
      end

      it "renders a page informing them the subscription has already ended" do
        post :confirmed, params: { id: id }

        expect(response.body).to include(
          I18n.t!("unsubscriptions.confirmation.with_title", title: title),
        )
      end
    end

    context "when a user is authenticated" do
      let(:session) do
        { "authentication" => { "subscriber_id" => subscriber_id } }
      end

      it "redirects to subscription management" do
        post :confirmed, params: { id: id }, session: session
        expect(response).to redirect_to(list_subscriptions_path)
      end

      it "sets a flash to confirm" do
        post :confirmed, params: { id: id }, session: session

        expect(flash[:success][:message]).to eq(
          I18n.t!("subscriptions_management.index.unsubscribe.message", title: title),
        )
      end
    end
  end
end
