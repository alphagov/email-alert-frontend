RSpec.describe SubscriptionAuthenticationController do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper
  include SessionHelper

  render_views

  describe "GET authenticate" do
    let(:address) { "someone@example.com" }
    let(:topic_id) { SecureRandom.uuid }
    let(:frequency) { "immediately" }
    let(:token) { nil }
    let(:params) { { topic_id: topic_id, frequency: frequency, token: token } }

    before do
      stub_email_alert_api_has_subscriber_list_by_slug(
        slug: topic_id,
        returned_attributes: { id: 123, title: "Title" },
      )

      stub_email_alert_api_creates_a_subscription(
        subscriber_list_id: 123,
        address: address,
        frequency: frequency,
      )
    end

    context "the token is valid" do
      let(:token) do
        encrypt_and_sign_token(data: { "topic_id" => topic_id, "address" => address })
      end

      it "redirects to the manage page" do
        get :authenticate, params: params
        expect(response).to redirect_to(list_subscriptions_path)
      end

      it "shows a success flash message" do
        get :authenticate, params: params
        expect(flash[:success][:message]).to eq(I18n.t!("subscription_authentication.authenticate.message"))

        expect(flash[:success][:description]).to eq(
          I18n.t!("subscription_authentication.authenticate.description.immediately", title: "Title"),
        )
      end

      it "creates a new session" do
        get :authenticate, params: params
        expect(session["authentication"]).to be_present
      end

      context "for a daily subscription" do
        let(:frequency) { "daily" }

        it "shows a success flash message" do
          get :authenticate, params: params

          expect(flash[:success][:description]).to eq(
            I18n.t!("subscription_authentication.authenticate.description.daily", title: "Title"),
          )
        end
      end

      context "for a weekly subscription" do
        let(:frequency) { "weekly" }

        it "shows a success flash message" do
          get :authenticate, params: params

          expect(flash[:success][:description]).to eq(
            I18n.t!("subscription_authentication.authenticate.description.weekly", title: "Title"),
          )
        end
      end
    end

    context "the token is expired" do
      let(:token) { encrypt_and_sign_token(expiry: 0) }

      it "shows an expired error page" do
        get :authenticate, params: params
        expect(response.body).to include(I18n.t!("subscription_authentication.expired.title"))
      end
    end

    context "the token is re-used" do
      let(:token) { encrypt_and_sign_token(data: { "topic_id" => "another" }) }

      it "shows a general error page" do
        get :authenticate, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "the frequency is invalid" do
      let(:frequency) { "foo" }

      let(:token) do
        encrypt_and_sign_token(data: { "topic_id" => topic_id, "address" => address })
      end

      it "shows a general error page" do
        get :authenticate, params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "the token is invalid" do
      let(:token) { "foo" }

      it "shows an expired error page" do
        get :authenticate, params: params
        expect(response.body).to include(I18n.t!("subscription_authentication.expired.title"))
      end
    end
  end
end
