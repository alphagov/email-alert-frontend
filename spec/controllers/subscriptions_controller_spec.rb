RSpec.describe SubscriptionsController do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests

  let(:topic_id) { "GOVUK123" }
  let(:subscriber_list_title) { "My exciting list" }
  let(:subscriber_list_id) { 10 }
  let(:subscriber_list_attributes) do
    {
      id: subscriber_list_id,
      title: subscriber_list_title,
    }
  end

  render_views

  before do
    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: topic_id,
      returned_attributes: subscriber_list_attributes,
    )
  end

  describe "GET /email/subscriptions/new" do
    context "when no topic is provided" do
      it "raises an error" do
        expect { get :new, params: {} }
          .to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when a topic that doesn't exist in Email Alert API is provided" do
      before do
        stub_email_alert_api_does_not_have_subscriber_list_by_slug(slug: topic_id)
      end

      it "returns 404" do
        get :new, params: { topic_id: }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a topic is provided" do
      it "returns 200" do
        get :new, params: { topic_id: }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a topic and frequency are provided" do
      let(:frequency) { "immediately" }
      it "returns 200" do
        get :new, params: { topic_id:, frequency: }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a topic and an invalid frequency are provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        get :new, params: { topic_id:, frequency: }
        expect(response).to redirect_to(new_subscription_url(topic_id:))
      end
    end
  end

  describe "POST /email/subscriptions/frequency" do
    context "when no frequency is provided" do
      it "renders an error" do
        post :frequency, params: { topic_id: }

        expect(response.body).to include(I18n.t!("subscriptions.new_frequency.missing_frequency"))
        expect(response).to have_http_status(:ok)
      end
    end

    context "when an invalid frequency is provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        post :frequency, params: { topic_id:, frequency: }
        expect(response).to redirect_to(new_subscription_url(topic_id:))
      end
    end

    context "when a valid frequency is provided" do
      let(:frequency) { "daily" }
      it "redirects to new with frequency" do
        post :frequency, params: { topic_id:, frequency: }
        destination = new_subscription_url(
          topic_id:, frequency:,
        )
        expect(response).to redirect_to(destination)
      end

      context "when the user is logged in" do
        before { mock_logged_in_session(session_id) }

        let(:session_id) { "session-id" }

        let!(:link_stub) do
          stub_email_alert_api_link_subscriber_to_govuk_account(
            session_id,
            subscriber_id,
            address,
            govuk_account_id: linked_govuk_account_id,
          )
        end

        let!(:create_stub) do
          stub_email_alert_api_creates_a_subscription(
            subscriber_list_id:,
            address:,
            frequency:,
            returned_subscription_id: subscription_id,
          )
        end

        let(:subscription_id) { 256 }
        let(:subscriber_id) { "subscriber-id" }
        let(:address) { "email@example.com" }
        let(:linked_govuk_account_id) { 42 }

        it "creates the subscription and redirects to the manage page" do
          post :frequency, params: { topic_id:, frequency: }
          expect(response).to redirect_to(list_subscriptions_path)
          expect(flash[:subscription][:id]).to eq(subscription_id)
          expect(link_stub).to have_been_made
          expect(create_stub).to have_been_made
        end

        context "when the session is invalid" do
          let!(:link_stub) do
            stub_email_alert_api_link_subscriber_to_govuk_account_session_invalid(session_id)
          end

          it "treats the user as logged out" do
            post :frequency, params: { topic_id:, frequency: }
            destination = new_subscription_url(
              topic_id:, frequency:,
            )
            expect(response).to redirect_to(destination)
          end
        end
      end
    end
  end

  describe "POST /email/subscriptions/verify" do
    let(:valid_email) { "joe@example.com" }

    context "when no frequency is provided" do
      it "redirects to new without the frequency" do
        post :verify, params: { topic_id:, address: valid_email }
        expect(response).to redirect_to(new_subscription_url(topic_id:))
      end
    end

    context "when no address is provided" do
      let(:params) { { topic_id:, frequency: "daily" } }

      it "renders an error" do
        post :verify, params: params
        expect(response.body).to include(I18n.t!("subscriptions.new_address.missing_email"))
        expect(response).to have_http_status(:ok)
      end
    end

    context "when an invalid email address is provided" do
      let(:address) { "bad-email" }
      let(:frequency) { "immediately" }

      let(:params) do
        { topic_id:, frequency:, address: }
      end

      before do
        stub_account_api_match_user_by_email_does_not_exist(email: address)
        stub_email_alert_api_subscription_verification_email_invalid(address, frequency, topic_id)
      end

      it "renders an error" do
        post :verify, params: params
        expect(response.body).to include(I18n.t!("subscriptions.new_address.invalid_email"))
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a valid email address is provided" do
      let(:address) { valid_email }
      let(:frequency) { "immediately" }

      let(:params) do
        { topic_id:, frequency:, address: }
      end

      let!(:verify_stub) do
        stub_email_alert_api_sends_subscription_verification_email(address, frequency, topic_id)
      end

      before do
        stub_account_api_match_user_by_email_does_not_exist(email: address)
      end

      it "renders a notice to check email" do
        post :verify, params: params
        expect(response.body).to include(I18n.t!("subscriptions.check_email.title"))
        expect(response).to have_http_status(:ok)
      end

      it "sends a request to email-alert-api" do
        post :verify, params: params
        expect(verify_stub).to have_been_requested
      end

      context "when the user is logged in" do
        before { mock_logged_in_session(session_id) }

        let(:session_id) { "session-id" }

        context "when there is an account with that email address" do
          before do
            stub_account_api_match_user_by_email_matches(email: address)
          end

          it "prompts the user to sign in to that account" do
            post :verify, params: params
            expect(response.body).to include(I18n.t!("subscriptions.use_your_govuk_account.heading"))
            expect(verify_stub).not_to have_been_requested
          end
        end

        context "when there is no account with that email address" do
          before do
            stub_account_api_match_user_by_email_does_not_exist(email: address)
          end

          it "sends a request to email-alert-api" do
            post :verify, params: params
            expect(verify_stub).to have_been_requested
          end
        end
      end
    end

    context "when there are too many requests for a particular address" do
      let(:params) do
        { topic_id:, frequency: "immediately", address: valid_email }
      end

      before do
        allow(VerifySubscriptionEmailService).to receive(:call)
          .and_raise(VerifySubscriptionEmailService::RatelimitExceededError)
      end

      it "returns a 429 reponse" do
        post :verify, params: params
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end
end
