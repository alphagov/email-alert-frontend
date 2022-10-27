RSpec.describe UnsubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi
  include SessionHelper
  include TokenHelper

  render_views

  let(:id) { SecureRandom.uuid }
  let(:subscriber_id) { 1 }
  let(:title) { "title" }

  before do
    stub_email_alert_api_has_subscription(
      id, "immediately", title:, subscriber_id:
    )
    stub_email_alert_api_unsubscribes_a_subscription(id)
  end

  shared_examples "requires authentication" do
    context "when the token is for a different subscription" do
      it "redirects to the sign in page" do
        token = encrypt_and_sign_token(data: { "subscriber_id" => "other" })
        make_request(params: { id:, token: })
        expect(response).to redirect_to sign_in_path
        expect(flash[:error]).to eq(:bad_token)
      end
    end

    context "when the token is expired" do
      it "redirects to the sign in page" do
        token = encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id }, expiry: 0)
        make_request(params: { id:, token: })
        expect(response).to redirect_to sign_in_path
        expect(flash[:error]).to eq(:bad_token)
      end
    end

    context "when the token is invalid" do
      it "redirects to the sign in page" do
        token = encrypt_and_sign_token(data: {})
        make_request(params: { id:, token: })
        expect(response).to redirect_to sign_in_path
        expect(flash[:error]).to eq(:bad_token)
      end
    end

    context "when the user has no authentication" do
      it "redirects to the sign in page" do
        make_request(params: { id: })
        expect(response).to redirect_to sign_in_path
        expect(flash[:error]).to be_nil
      end
    end
  end

  describe "GET /email/unsubscribe/:id" do
    def make_request(params:, session: nil)
      get :confirm, params:, session:
    end

    it_behaves_like "requires authentication"

    context "when the user has a one-click link" do
      it "responds with a 200" do
        token = encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id })
        make_request(params: { id:, token: })
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is signed in" do
      it "responds with a 200" do
        make_request(params: { id: }, session: session_for(subscriber_id))
        expect(response).to have_http_status(:ok)
      end
    end

    context "when the subscription has already ended" do
      before do
        stub_email_alert_api_has_subscription(
          id, "immediately", ended: true, title: "VAT Rates"
        )
      end

      it "show a message saying subscription has ended" do
        make_request(params: { id: }, session: session_for(subscriber_id))
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
        token = encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id })
        make_request(params: { id: original_subscription_id, token: })

        expected_path = confirm_unsubscribe_path(latest_subscription_id, token:)
        expect(response).to redirect_to(expected_path)
      end
    end
  end

  describe "POST /email/unsubscribe/:id" do
    def make_request(params:, session: nil)
      post :confirmed, params:, session:
    end

    it_behaves_like "requires authentication"

    context "when the user has a one-click link" do
      let(:token) { encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id }) }

      it "responds with a 200" do
        make_request(params: { id:, token: })
        expect(response).to have_http_status(:ok)
      end

      it "renders a confirmation page" do
        make_request(params: { id:, token: })

        expect(response.body).to include(
          I18n.t!("unsubscriptions.confirmation.with_title", title:),
        )
      end

      it "sends an unsubscribe request to email-alert-api" do
        make_request(params: { id:, token: })
        assert_unsubscribed(id)
      end
    end

    context "when the user has already unsubscribed" do
      before do
        stub_email_alert_api_has_no_subscription_for_uuid(id)
      end

      it "renders a confirmation page" do
        token = encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id })
        make_request(params: { id:, token: })

        expect(response.body).to include(
          I18n.t!("unsubscriptions.confirmation.with_title", title:),
        )
      end
    end

    context "when a user is signed in" do
      let(:session) { session_for(subscriber_id) }

      it "sends an unsubscribe request to email-alert-api" do
        make_request(params: { id: }, session:)
        assert_unsubscribed(id)
      end

      it "redirects to subscription management" do
        make_request(params: { id: }, session:)
        expect(response).to redirect_to(list_subscriptions_path)
      end

      it "sets a flash to confirm" do
        make_request(params: { id: }, session:)

        expect(flash[:success][:message]).to eq(
          I18n.t!("subscriptions_management.index.unsubscribe.message", title:),
        )
      end
    end
  end
end
