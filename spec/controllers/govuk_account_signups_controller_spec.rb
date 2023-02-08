RSpec.describe GovukAccountSignupsController do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests

  render_views

  let(:base_path) { "/test" }
  let(:topic_slug) { SecureRandom.uuid }
  let(:topic_name) { "Test" }
  let(:redirect_path) { "/email/subscriptions/account/confirm?frequency=immediately&return_to_url=true&topic_id=#{topic_slug}" }
  let(:auth_provider) { "http://auth/provider" }
  let(:description) { "A list description" }

  describe "POST /email/subscriptions/single-page/new-session" do
    before { stub_account_api_get_sign_in_url(auth_uri: auth_provider, redirect_path:) }

    let(:params) { { topic_id: topic_slug } }

    it "redirects to sign in with a redirect_path param" do
      post(:edit, params:)
      expect(response).to redirect_to(auth_provider.to_s)
    end

    it "redirects with _ga param and cookie_consent if present in the request params" do
      post :edit, params: params.merge({ _ga: "abc123", cookie_consent: "accept" })
      expect(response).to redirect_to("#{auth_provider}?_ga=abc123&cookie_consent=accept")
    end

    it "returns 404 if no topic_id parameter is provided" do
      post :edit
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /email/subscriptions/single-page/new" do
    before do
      stub_content_store_has_item(base_path, content_item_for_base_path(base_path).merge("content_id" => content_id, "description" => description))

      stub_email_alert_api_creates_subscriber_list({
        url: base_path,
        title: topic_name,
        slug: topic_slug,
        id: subscription_list_id,
        content_id:,
        description:,
      })
    end

    let(:content_id) { SecureRandom.uuid }
    let(:subscription_list_id) { "subscription-list-id" }
    let(:params) { { base_path: } }

    it "404s when a content item can't be found" do
      stub_content_store_does_not_have_item(base_path)
      post(:create, params:)
      expect(response).to have_http_status(:not_found)
    end

    it "422s and writes to the log when a bad base path is passed" do
      expect(Rails.logger).to receive(:warn)
      post :create, params: { base_path: "/invalid{}" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "when a user is not logged in" do
      it "redirects to show and renders a sign in link including the topic_id" do
        post(:create, params:)
        expect(response).to redirect_to(new_govuk_account_signup_path(topic_id: topic_slug))
      end
    end

    context "when a user is logged in" do
      let(:session_id) { "session-id" }
      let(:user_id) { "user-id" }
      let(:subscriber_id) { "subscriber-id" }
      let(:user_email) { "test@gov.uk" }

      before do
        mock_logged_in_session(session_id)
        stub_account_api_get_sign_in_url(auth_uri: auth_provider, redirect_path:)

        stub_email_alert_api_authenticate_subscriber_by_govuk_account(
          session_id,
          subscriber_id,
          user_email,
          govuk_account_id: user_id,
        )

        stub_email_alert_api_has_subscriber_subscriptions(
          subscriber_id,
          user_email,
          subscriptions: [],
        )

        stub_email_alert_api_creates_a_subscription(
          subscriber_list_id: subscription_list_id,
          address: user_email,
          frequency: "immediately",
          returned_subscription_id: "subscription-id",
          subscriber_id:,
        )

        stub_email_alert_api_link_subscriber_to_govuk_account(
          session_id,
          subscriber_id,
          user_email,
          govuk_account_id: user_id,
        )
      end

      it "logs the user out if the session is invalid" do
        stub_email_alert_api_link_subscriber_to_govuk_account_session_invalid(session_id)
        post(:create, params:)
        expect(response).to redirect_to(auth_provider.to_s)
      end

      it "subscribes them and redirects back to the page" do
        post(:create, params:)
        expect(response).to redirect_to("http://test.host#{base_path}")
      end

      context "when the user is already subscribed to that base_path" do
        let(:subscription_id) { "subscription-id" }

        before do
          stub_email_alert_api_has_subscriber_subscriptions(
            subscriber_id,
            user_email,
            subscriptions: [
              {
                "subscriber_id" => subscriber_id,
                "subscriber_list_id" => subscription_list_id,
                "frequency" => "immediately",
                "id" => subscription_id,
                "subscriber_list" => {
                  "id" => subscription_list_id,
                  "slug" => base_path,
                },
              },
            ],
          )
        end

        it "unsubscribes them and redirects back to the page" do
          unsubscribe_stub = stub_email_alert_api_unsubscribes_a_subscription(subscription_id)

          post(:create, params:)
          expect(response).to redirect_to("http://test.host#{base_path}")
          expect(unsubscribe_stub).to have_been_made
        end
      end
    end
  end

  describe "GET /email/subscriptions/single-page/new" do
    let(:params) { { topic_id: topic_slug } }

    it "returns 404 if no topic_id parameter is provided" do
      get :show
      expect(response).to have_http_status(:not_found)
    end

    it "returns 200 if a topic_id parameter is provided and renders an information page" do
      get(:show, params:)
      expect(response).to have_http_status(:ok)
    end
  end
end
