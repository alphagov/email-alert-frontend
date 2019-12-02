RSpec.describe SubscriptionAuthenticationController do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  render_views

  describe "GET authenticate" do
    let(:address) { "someone@example.com" }
    let(:topic_id) { SecureRandom.uuid }
    let(:params) { { topic_id: topic_id, frequency: "immediately" } }

    context "the token is valid" do
      before do
        stub_email_alert_api_has_subscriber_list_by_slug(
          slug: topic_id,
          returned_attributes: { id: 123 },
        )

        stub_email_alert_api_creates_a_subscription(
          123,
          address,
          params[:frequency],
          nil,
        )
      end

      let(:token) do
        jwt_token(data: { "topic_id" => topic_id, "address" => address })
      end

      it "redirects to the success page" do
        get :authenticate, params: params.merge(token: token)
        expect(response).to redirect_to(subscription_path(params))
      end

      it "sets the Cache-Control header to 'private, no-cache'" do
        get :authenticate, params: params.merge(token: token)
        expect(response.headers["Cache-Control"]).to eq("private, no-cache")
      end
    end

    context "the token is expired" do
      let(:token) { jwt_token(expiry: 5.minutes.ago) }

      it "shows an expired error page" do
        get :authenticate, params: params.merge(token: token)
        expect(response.body).to include(I18n.t!("subscription_authentication.title"))
      end
    end

    context "the token is re-used" do
      let(:token) { jwt_token(data: { "topic_id" => "another" }) }

      it "shows a general error page" do
        get :authenticate, params: params.merge(token: token)
        expect(response.status).to eq 422
      end
    end

    context "the frequency is invalid" do
      let(:token) do
        jwt_token(data: { "topic_id" => topic_id, "address" => address })
      end

      it "shows a general error page" do
        get :authenticate, params: params.merge(token: token, frequency: "foo")
        expect(response.status).to eq 422
      end
    end

    context "the token is invalid" do
      it "shows an expired error page" do
        get :authenticate, params: params.merge(token: "foo")
        expect(response.body).to include(I18n.t!("subscription_authentication.title"))
      end
    end
  end
end
