RSpec.describe SubscriberAuthenticationController do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests
  include TokenHelper
  include SessionHelper

  let(:endpoint) { GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT }
  let(:subscriber_id) { 1 }
  let(:subscriber_address) { "test@example.com" }

  render_views

  describe "GET /email/authenticate" do
    context "when the page is requested" do
      it "returns 200" do
        get :sign_in
        expect(response).to have_http_status(:ok)
      end

      it "renders a form" do
        get :sign_in
        expect(response.body).to include(%(action="#{verify_subscriber_path}"))
      end
    end
  end

  describe "POST /email/authenticate" do
    context "when no address is provided" do
      let(:subscriber_address) { "" }

      it "renders an error message" do
        post :verify, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.sign_in.missing_email.description"))
      end
    end

    context "when an invalid address is provided" do
      let(:subscriber_address) { "foobar" }

      before do
        stub_account_api_match_user_by_email_does_not_exist(email: subscriber_address)
        stub_email_alert_api_subscriber_verification_email_invalid
      end

      it "renders an error message" do
        post :verify, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.sign_in.invalid_email.description"))
      end
    end

    context "when the email address is linked to a GOV.UK account" do
      before do
        stub_email_alert_api_subscriber_verification_email_linked_to_govuk_account
        stub_account_api_match_user_by_email_does_not_match(email: subscriber_address)
      end

      it "tells the user to sign in with their account" do
        post :verify, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.use_your_govuk_account.heading"))
      end

      context "when the user is currently logged in to that account" do
        before do
          mock_logged_in_session("session-id")
          stub_account_api_match_user_by_email_matches(email: subscriber_address, govuk_account_session: "session-id")
        end

        it "redirects the user to authenticate" do
          post :verify, params: { address: subscriber_address }
          expect(response).to redirect_to(process_govuk_account_path)
        end
      end
    end

    context "when a valid address is provided and the subscriber doesn't exist" do
      before do
        stub_account_api_match_user_by_email_does_not_exist(email: subscriber_address)
        stub_email_alert_api_subscriber_verification_email_no_subscriber
        post :verify, params: { address: subscriber_address }
      end

      it "renders no_subscriber header" do
        expect(response.body).to include(I18n.t!("subscriber_authentication.no_subscriber.heading"))
      end
    end

    context "when a valid address is provided and the subscriber exists" do
      before do
        stub_account_api_match_user_by_email_does_not_exist(email: subscriber_address)
        stub_email_alert_api_sends_subscriber_verification_email(subscriber_id, subscriber_address)
      end

      it "renders a message" do
        post :verify, params: { address: subscriber_address }
        expect(response.body).to include(I18n.t!("subscriber_authentication.check_email.heading"))
      end
    end

    context "when there are too many requests for a particular address" do
      before do
        allow(VerifySubscriberEmailService).to receive(:call)
          .and_raise(VerifySubscriberEmailService::RatelimitExceededError)
      end

      it "returns a 429 reponse" do
        post :verify, params: { address: subscriber_address }
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end

  describe "GET /email/authenticate/process" do
    let(:token) do
      encrypt_and_sign_token(data: { "subscriber_id" => subscriber_id })
    end

    context "when an expired token is provided" do
      let(:expired_token) { encrypt_and_sign_token(expiry: 0) }

      it "redirects to sign in" do
        get :process_sign_in_token, params: { token: expired_token }
        expect(response).to redirect_to(sign_in_path)
      end

      it "sets a bad_token flash" do
        get :process_sign_in_token, params: { token: expired_token }
        expect(flash[:error]).to eq(:bad_token)
      end

      it "clears any existing session" do
        get :process_sign_in_token,
            params: { token: expired_token },
            session: session_for(subscriber_id)

        expect(session.to_h).to_not include(session_for(subscriber_id))
      end
    end

    context "when a valid token is provided" do
      it "redirects to the subscription management page" do
        get :process_sign_in_token, params: { token: }
        expect(response).to redirect_to(list_subscriptions_path)
      end

      it "creates a session for the subscriber" do
        get :process_sign_in_token, params: { token: }
        expect(session.to_h).to include(session_for(subscriber_id))
      end
    end
  end

  describe "GET /email/authenticate/account" do
    before do
      mock_logged_in_session(session_id)
      stub_email_alert_api_link_subscriber_to_govuk_account(session_id, subscriber_id, subscriber_address, new_govuk_account_session: new_session_id)
    end

    let(:session_id) { "session-id" }
    let(:new_session_id) { nil }

    it "redirects to the subscription management page" do
      get :process_govuk_account
      expect(response).to redirect_to(list_subscriptions_path)
    end

    it "passes on _ga and cookie_consent parameters in the redirect if present" do
      get :process_govuk_account, params: { _ga: "abc123", cookie_consent: "accept" }
      expect(response).to redirect_to(list_subscriptions_path(_ga: "abc123", cookie_consent: "accept"))
    end

    it "does not create a new session" do
      get :process_govuk_account
      expect(session["authentication"]).to be_nil
    end

    it "clears any existing session" do
      get :process_govuk_account, session: session_for(subscriber_id)
      expect(session["authentication"]).to be_nil
    end

    it "sets the Vary response header" do
      get :process_govuk_account
      expect(response.headers["Vary"]).to include("GOVUK-Account-Session")
    end

    context "when email-alert-api returns a new session ID" do
      let(:new_session_id) { "new-session-id" }

      it "includes a new session ID in the response headers" do
        get :process_govuk_account
        expect(response.headers["GOVUK-Account-Session"]).to eq(new_session_id)
      end
    end

    context "when the user's session is missing" do
      before do
        stub_account_api_get_sign_in_url(redirect_path: "/email/manage/authenticate/account", auth_uri:)
      end

      let(:session_id) { nil }

      let(:auth_uri) { "/sign-in" }

      it "redirects them to sign in" do
        get :process_govuk_account
        expect(response).to redirect_to(auth_uri)
      end
    end

    context "when the user's session is invalid" do
      before do
        stub_email_alert_api_link_subscriber_to_govuk_account_session_invalid(session_id)
        stub_account_api_get_sign_in_url(redirect_path: "/email/manage/authenticate/account", auth_uri:)
      end

      let(:auth_uri) { "/sign-in" }

      it "redirects them to sign in" do
        get :process_govuk_account
        expect(response).to redirect_to(auth_uri)
      end

      it "sets the logout session header" do
        get :process_govuk_account
        expect(response.headers["GOVUK-Account-End-Session"]).to_not be_nil
      end
    end

    context "when the account email address is unverified" do
      before do
        stub_email_alert_api_link_subscriber_to_govuk_account_email_unverified(session_id, new_govuk_account_session: new_session_id)
        stub_account_api_get_sign_in_url(redirect_path: "/email/manage/authenticate/account", auth_uri:)
      end

      let(:auth_uri) { "/sign-in" }

      it "redirects users to sign in again" do
        get :process_govuk_account
        expect(response).to redirect_to(auth_uri)
      end
    end
  end
end
