RSpec.describe AccountSubscriptionsController do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests

  let(:session_id) { "session-id" }
  let(:subscriber_id) { 256 }
  let(:address) { "email@example.com" }
  let(:linked_govuk_account_id) { nil }
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
    mock_logged_in_session(session_id)

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: topic_id,
      returned_attributes: subscriber_list_attributes,
    )
  end

  describe "GET /email/subscriptions/account/confirm" do
    before do
      stub_email_alert_api_authenticate_subscriber_by_govuk_account(
        session_id,
        subscriber_id,
        address,
        govuk_account_id: linked_govuk_account_id,
      )

      stub_email_alert_api_has_subscriber_subscriptions(
        subscriber_id,
        address,
        subscriptions: active_subscriptions,
      )
    end

    let(:active_subscriptions) { [] }

    it "raises a parameter missing error" do
      expect { get :confirm, params: {} }.to raise_error(ActionController::ParameterMissing)
    end

    context "when a topic is provided" do
      it "returns 200" do
        get :confirm, params: { topic_id: }
        expect(response).to have_http_status(:ok)
      end

      it "does not list any active subscriptions" do
        get :confirm, params: { topic_id: }
        expect(response.body).not_to include(I18n.t("account_subscriptions.confirm.unlinked_subscriptions.title"))
      end

      context "when the user has active subscriptions" do
        let(:active_subscriptions) do
          [
            { subscriber_list: { title: "First Subscription" } },
            { subscriber_list: { title: "Second Subscription" } },
            { subscriber_list: { title: "Third Subscription" } },
          ]
        end

        it "shows the topic sign-up description" do
          get :confirm, params: { topic_id: }
          expect(response.body).to include(I18n.t("account_subscriptions.confirm.description.topic"))
        end

        it "lists them" do
          get :confirm, params: { topic_id: }
          expect(response.body).to include(I18n.t("account_subscriptions.confirm.unlinked_subscriptions.title"))
          active_subscriptions.each do |subscription|
            expect(response.body).to include(subscription.dig(:subscriber_list, :title))
          end
        end

        context "when the user is linked to a GOV.UK account" do
          let(:linked_govuk_account_id) { "user-id" }

          it "does not list them" do
            get :confirm, params: { topic_id: }
            expect(response.body).not_to include(I18n.t("account_subscriptions.confirm.unlinked_subscriptions.title"))
            active_subscriptions.each do |subscription|
              expect(response.body).not_to include(subscription.dig(:subscriber_list, :title))
            end
          end
        end

        context "when the subscriberlist is for a single page" do
          let(:subscriber_list_attributes) do
            {
              id: subscriber_list_id,
              title: subscriber_list_title,
              content_id: SecureRandom.uuid,
            }
          end

          it "shows the page sign-up description" do
            get :confirm, params: { topic_id: }
            expect(response.body).to include(I18n.t("account_subscriptions.confirm.description.page"))
          end

          context "when the user is already subscribed to this subscriber list" do
            let(:subscriber_list_attributes) do
              {
                id: subscriber_list_id,
                title: subscriber_list_title,
                content_id: SecureRandom.uuid,
                url:,
              }
            end

            let(:url) { "/some/page" }

            let(:active_subscriptions) do
              [
                { subscriber_list: subscriber_list_attributes },
              ]
            end

            it "redirects them to the list URL" do
              get :confirm, params: { topic_id: }
              expect(response).to redirect_to(subscriber_list_attributes[:url])
            end

            context "when the list has no URL" do
              let(:url) { nil }

              it "redirects them to the management page" do
                get :confirm, params: { topic_id: }
                expect(response).to redirect_to(list_subscriptions_path)
              end
            end
          end
        end
      end

      context "when a frequency is provided" do
        let(:frequency) { "immediately" }

        it "returns 200" do
          get :confirm, params: { topic_id:, frequency: }
          expect(response).to have_http_status(:ok)
        end

        context "when the frequency is invalid" do
          let(:frequency) { "foobar" }

          it "redirects back without the frequency" do
            get :confirm, params: { topic_id:, frequency: }
            expect(response).to redirect_to(confirm_account_subscription_url(topic_id:))
          end
        end
      end

      context "when the topic doesn't exist in Email Alert API" do
        before do
          stub_email_alert_api_does_not_have_subscriber_list_by_slug(slug: topic_id)
        end

        it "returns a 404" do
          get :confirm, params: { topic_id: }
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the user has no session" do
        before do
          mock_logged_in_session(nil)
          stub_account_api_get_sign_in_url(
            redirect_path: "/email/subscriptions/account/confirm?frequency=#{AccountSubscriptionsController::DEFAULT_FREQUENCY}&topic_id=#{topic_id}",
            auth_uri:,
          )
        end

        let(:auth_uri) { "/sign-in" }

        it "logs the user out and redirects to sign in" do
          get :confirm, params: { topic_id: }
          expect(response.headers["GOVUK-Account-End-Session"]).to_not be_nil
          expect(response).to redirect_to(auth_uri)
        end
      end

      context "when the user's session is invalid" do
        before do
          stub_email_alert_api_authenticate_subscriber_by_govuk_account_session_invalid(session_id)
          stub_account_api_get_sign_in_url(
            redirect_path: "/email/subscriptions/account/confirm?frequency=#{AccountSubscriptionsController::DEFAULT_FREQUENCY}&topic_id=#{topic_id}",
            auth_uri:,
          )
        end

        let(:auth_uri) { "/sign-in" }

        it "logs the user out and redirects to sign in" do
          get :confirm, params: { topic_id: }
          expect(response.headers["GOVUK-Account-End-Session"]).to_not be_nil
          expect(response).to redirect_to(auth_uri)
        end
      end
    end
  end

  describe "POST /email/subscriptions/account" do
    before do
      stub_email_alert_api_link_subscriber_to_govuk_account(
        session_id,
        subscriber_id,
        address,
        govuk_account_id: linked_govuk_account_id,
      )
    end

    let(:linked_govuk_account_id) { "user-id" }

    it "raises a parameter missing error" do
      expect { post :create, params: {} }.to raise_error(ActionController::ParameterMissing)
    end

    context "when a topic is provided" do
      let!(:create_stub) do
        stub_email_alert_api_creates_a_subscription(
          subscriber_list_id:,
          address:,
          frequency: created_frequency,
          returned_subscription_id: subscription_id,
        )
      end

      let(:subscription_id) { 256 }

      let(:created_frequency) { AccountSubscriptionsController::DEFAULT_FREQUENCY }

      it "creates the subscription with a default frequency, links the subscriber to the GOV.UK account, and redirects to the manage page" do
        post :create, params: { topic_id: }
        expect(flash[:subscription][:id]).to eq(subscription_id)
        expect(response).to redirect_to(list_subscriptions_path)
        expect(create_stub).to have_been_made
      end

      context "when a frequency is provided" do
        let(:frequency) { "immediately" }
        let(:created_frequency) { frequency }

        it "creates the subscription with the correct frequency" do
          post :create, params: { topic_id:, frequency: }
          expect(response).to redirect_to(list_subscriptions_path)
          expect(create_stub).to have_been_made
        end

        context "when the frequency is invalid" do
          let(:frequency) { "foobar" }

          it "redirects back without the frequency" do
            post :create, params: { topic_id:, frequency: }
            expect(response).to redirect_to(confirm_account_subscription_url(topic_id:))
            expect(create_stub).not_to have_been_made
          end
        end
      end

      context "when the topic has a URL" do
        let(:subscriber_list_attributes) do
          {
            id: subscriber_list_id,
            title: subscriber_list_title,
            url: "/some/page",
          }
        end

        it "redirects to the manage page when the return_to_url parameter is not given" do
          post :create, params: { topic_id: }
          expect(response).to redirect_to(list_subscriptions_path)
        end

        it "redirects to the manage page when the return_to_url parameter is given" do
          post :create, params: { topic_id:, return_to_url: "1" }
          expect(response).to redirect_to(subscriber_list_attributes[:url])
        end
      end

      context "when the topic doesn't exist in Email Alert API" do
        before do
          stub_email_alert_api_does_not_have_subscriber_list_by_slug(slug: topic_id)
        end

        it "returns a 404" do
          post :create, params: { topic_id: }
          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the user's session is invalid" do
        before do
          stub_email_alert_api_link_subscriber_to_govuk_account_session_invalid(session_id)
          stub_account_api_get_sign_in_url(
            redirect_path: "/email/subscriptions/account/confirm?frequency=#{AccountSubscriptionsController::DEFAULT_FREQUENCY}&topic_id=#{topic_id}",
            auth_uri:,
          )
        end

        let(:auth_uri) { "/sign-in" }

        it "logs the user out and redirects to sign in" do
          post :create, params: { topic_id: }
          expect(response.headers["GOVUK-Account-End-Session"]).to_not be_nil
          expect(response).to redirect_to(auth_uri)
        end
      end
    end
  end
end
