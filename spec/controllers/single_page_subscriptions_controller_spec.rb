RSpec.describe SinglePageSubscriptionsController do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests

  render_views

  let(:base_path) { "/test" }
  let(:topic_slug) { SecureRandom.uuid }
  let(:topic_name) { "Test" }
  let(:redirect_path) { "/email/subscriptions/account/confirm?topic_id=#{topic_slug}" }
  let(:auth_provider) { "http://auth/provider" }

  describe "when feature flag is not 'enabled'" do
    it "POST /email/subscriptions/single-page/new-session returns 404" do
      post :edit
      expect(response).to have_http_status(:not_found)
    end

    it "POST /email/subscriptions/single-page/new" do
      post :show
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when the feature is on" do
    around do |example|
      ClimateControl.modify FEATURE_FLAG_GOVUK_ACCOUNT: "enabled" do
        example.run
      end
    end

    describe "POST /email/subscriptions/single-page/new-session" do
      before { stub_account_api_get_sign_in_url(auth_uri: auth_provider, redirect_path: redirect_path) }

      let(:params) { { topic_id: topic_slug } }

      it "redirects to sign in with a redirect_path param" do
        post :edit, params: params
        expect(response).to redirect_to(auth_provider.to_s)
      end

      it "redirects with _ga param and cookie_consent if present in the request params" do
        post :edit, params: params.merge({ _ga: "abc123", cookie_consent: "accept" })
        expect(response).to redirect_to("#{auth_provider}?_ga=abc123&cookie_consent=accept")
      end
    end

    describe "POST /email/subscriptions/single-page/new" do
      before do
        stub_content_store_has_item(base_path, content_item_for_base_path(base_path).merge("content_id" => content_id))

        stub_email_alert_api_creates_subscriber_list({
          url: base_path,
          title: topic_name,
          slug: topic_slug,
          id: subscription_list_id,
          content_id: content_id,
        })
      end

      let(:content_id) { SecureRandom.uuid }
      let(:subscription_list_id) { "subscription-list-id" }
      let(:params) { { base_path: base_path } }

      it "404s when a content item can't be found" do
        stub_content_store_does_not_have_item(base_path)
        get :show, params: params
        expect(response).to have_http_status(:not_found)
      end

      context "when a user is not logged in" do
        it "renders the view with a sign in link including the base_path" do
          get :show, params: params
          expect(response.body).to include(single_page_new_session_path)
        end
      end

      context "when a user is logged in" do
        let(:session_id) { "session-id" }
        let(:user_id) { "user-id" }
        let(:subscriber_id) { "subscriber-id" }
        let(:user_email) { "test@gov.uk" }

        before do
          mock_logged_in_session(session_id)
          stub_account_api_get_sign_in_url(auth_uri: auth_provider, redirect_path: redirect_path)

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
            frequency: "daily",
            returned_subscription_id: "subscription-id",
            subscriber_id: subscriber_id,
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
          post :show, params: params
          expect(response).to redirect_to(auth_provider.to_s)
        end

        it "subscribes them and redirects back to the page" do
          post :show, params: params
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
                  "frequency" => "daily",
                  "id" => subscription_id,
                  "subscriber_list" => {
                    "id" => subscription_list_id,
                    "slug" => base_path,
                  },
                },
              ],
            )
            stub_email_alert_api_unsubscribes_a_subscription(subscription_id)
          end

          it "unsubscribes them and redirects back to the page" do
            post :show, params: params
            expect(response).to redirect_to("http://test.host#{base_path}")
          end
        end
      end
    end
  end
end
