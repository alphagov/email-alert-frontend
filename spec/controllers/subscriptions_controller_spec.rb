RSpec.describe SubscriptionsController do
  include GdsApi::TestHelpers::EmailAlertApi

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
        get :new, params: { topic_id: topic_id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when a topic is provided" do
      it "returns 200" do
        get :new, params: { topic_id: topic_id }
        expect(response).to have_http_status(:ok)
      end

      it "sets the Cache-Control header to 'private, no-cache'" do
        get :new, params: { topic_id: topic_id }
        expect(response.headers["Cache-Control"]).to eq("private, no-cache")
      end
    end

    context "when a topic and frequency are provided" do
      let(:frequency) { "immediately" }
      it "returns 200" do
        get :new, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when a topic and an invalid frequency are provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        get :new, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end
  end

  describe "POST /email/subscriptions/frequency" do
    context "when no frequency is provided" do
      it "renders an error" do
        post :frequency, params: { topic_id: topic_id }

        expect(response.body).to include(I18n.t!("subscriptions.new_frequency.missing_frequency"))
        expect(response).to have_http_status(:ok)
      end
    end

    context "when an invalid frequency is provided" do
      let(:frequency) { "foobar" }
      it "redirects to new without the frequency" do
        post :frequency, params: { topic_id: topic_id, frequency: frequency }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end

    context "when a valid frequency is provided" do
      let(:frequency) { "daily" }
      it "redirects to new with frequency" do
        post :frequency, params: { topic_id: topic_id, frequency: frequency }
        destination = new_subscription_url(
          topic_id: topic_id, frequency: frequency,
        )
        expect(response).to redirect_to(destination)
      end

      it "sets the Cache-Control header to 'private, no-cache'" do
        post :frequency, params: { topic_id: topic_id, frequency: frequency }
        expect(response.headers["Cache-Control"]).to eq("private, no-cache")
      end
    end
  end

  describe "POST /email/subscriptions/verify" do
    let(:valid_email) { "joe@example.com" }

    context "when no frequency is provided" do
      it "redirects to new without the frequency" do
        post :verify, params: { topic_id: topic_id, address: valid_email }
        expect(response).to redirect_to(new_subscription_url(topic_id: topic_id))
      end
    end

    context "when no address is provided" do
      let(:params) { { topic_id: topic_id, frequency: "daily" } }

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
        { topic_id: topic_id, frequency: frequency, address: address }
      end

      before do
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
        { topic_id: topic_id, frequency: frequency, address: address }
      end

      let!(:request) do
        stub_email_alert_api_sends_subscription_verification_email(address, frequency, topic_id)
      end

      it "renders a notice to check email" do
        post :verify, params: params
        expect(response.body).to include(I18n.t!("subscriptions.check_email.title"))
        expect(response).to have_http_status(:ok)
      end

      it "sends a request to email-alert-api" do
        post :verify, params: params
        expect(request).to have_been_requested
      end

      it "sets the Cache-Control header to 'private, no-cache'" do
        post :verify, params: params
        expect(response.headers["Cache-Control"]).to eq("private, no-cache")
      end
    end
  end
end
