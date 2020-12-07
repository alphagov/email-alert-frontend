RSpec.describe SubscriberAuthenticationController do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  let(:endpoint) { GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT }
  let(:subscriber_id) { 1 }
  let(:subscriber_address) { "test@example.com" }

  render_views

  before do
    stub_email_alert_api_sends_subscriber_verification_email(subscriber_id, subscriber_address)
  end

  describe "GET /email/authenticate" do
    context "when the page is requested" do
      it "returns 200" do
        get :sign_in
        expect(response).to have_http_status(:ok)
      end

      it "renders a form" do
        get :sign_in
        expect(response.body).to include(%(action="#{request_sign_in_token_path}"))
      end
    end
  end

  describe "POST /email/authenticate" do
    context "when no address is provided" do
      let(:subscriber_address) { "" }

      it "renders an error message" do
        post :request_sign_in_token, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.sign_in.missing_email"))
      end
    end

    context "when an invalid address is provided" do
      let(:subscriber_address) { "foobar" }

      before do
        stub_email_alert_api_subscriber_verification_email_invalid
      end

      it "renders an error message" do
        post :request_sign_in_token, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.sign_in.invalid_email"))
      end
    end

    context "when a valid address is provided and the subscriber doesn't exist" do
      before do
        stub_email_alert_api_subscriber_verification_email_no_subscriber
      end

      it "renders a message" do
        post :request_sign_in_token, params: { address: subscriber_address }
        expect(response.body).to include("We’ve sent an email to #{subscriber_address}")
      end
    end

    context "when a valid address is provided and the subscriber exists" do
      it "renders a message" do
        post :request_sign_in_token, params: { address: subscriber_address }
        expect(response.body).to include("We’ve sent an email to #{subscriber_address}")
      end
    end

    context "when there are too many requests for a particular address" do
      before do
        allow(VerifySubscriberEmailService).to receive(:call)
          .and_raise(VerifySubscriberEmailService::RatelimitExceededError)
      end

      it "returns a 429 reponse" do
        post :request_sign_in_token, params: { address: subscriber_address }
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end

  describe "GET /email/authenticate/process" do
    let(:token) do
      encrypt_and_sign_token(data: {
        "subscriber_id" => subscriber_id,
        "redirect" => "/email/manage",
      })
    end

    context "when an expired token is provided" do
      let(:expired_token) { encrypt_and_sign_token(expiry: 0) }

      it "redirects to sign in" do
        get :process_sign_in_token, params: { token: expired_token }
        expect(response).to redirect_to(sign_in_path)
      end

      it "sets a bad_token flash" do
        get :process_sign_in_token, params: { token: expired_token }
        expect(flash[:error_summary]).to eq("bad_token")
      end
    end

    context "when a valid token is provided" do
      it "redirects to the subscription management page" do
        get :process_sign_in_token, params: { token: token }
        expect(response).to redirect_to(list_subscriptions_path)
      end
    end
  end
end
