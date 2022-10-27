RSpec.describe EmailAlertSignup do
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::EmailAlertApi

  let(:mock_subscriber_list) do
    mock_response(subscriber_list: { slug: "topic-id" })
  end

  let(:api_client) { double(:api_client, find_or_create_subscriber_list: mock_subscriber_list) }
  let(:travel_index_item) { govuk_content_schema_example("travel_advice_index_email_alert_signup") }
  let(:travel_country_item) { govuk_content_schema_example("travel_advice_country_email_alert_signup") }

  before do
    allow(GdsApi).to receive(:email_alert_api).and_return(api_client)
  end

  def mock_response(body)
    GdsApi::Response.new(
      double(
        "net http response",
        code: 200,
        body: body.to_json,
        headers: {},
      ),
    )
  end

  it "is invalid with no signup page" do
    expect(EmailAlertSignup.new(nil)).not_to be_valid
  end

  it "does not attempt to create a subscription if no signup page is provided" do
    expect(api_client).not_to receive(:find_or_create_subscriber_list)

    expect(EmailAlertSignup.new(nil).find_or_create).to eq(false)
  end

  describe "#find_or_create" do
    context "when the signup page is for a travel advice country" do
      let(:signup_page) { mock_response(travel_country_item) }

      it "sends the correct subscription params to the email alert api" do
        expect(api_client).to receive(:find_or_create_subscriber_list)
          .with(
            match_array(
              "title" => "Afghanistan travel advice",
              "links" => { "countries" => %w[5a292f20-a9b6-46ea-b35f-584f8b3d7392] },
              "document_type" => "travel_advice",
            ),
          )
          .and_return(mock_subscriber_list)

        email_signup = EmailAlertSignup.new(signup_page)
        email_signup.find_or_create
      end
    end

    context "when the signup page is for the travel advice index" do
      let(:signup_page) { mock_response(travel_index_item) }

      it "sends the correct subscription params to the email alert api" do
        expect(api_client).to receive(:find_or_create_subscriber_list)
          .with(
            match_array(
              "title" => "Foreign travel advice",
              "document_type" => "travel_advice",
            ),
          )
          .and_return(mock_subscriber_list)

        email_signup = EmailAlertSignup.new(signup_page)
        email_signup.find_or_create
      end
    end
  end

  describe "#subscription_url" do
    let(:signup_page) { mock_response(travel_country_item) }

    it "is the subscription_url returned by the API" do
      expect(api_client).to receive(:find_or_create_subscriber_list)
        .and_return(mock_subscriber_list)

      email_signup = EmailAlertSignup.new(signup_page)
      email_signup.find_or_create

      expect(email_signup.subscription_url)
        .to eq("/email/subscriptions/new?topic_id=topic-id")
    end
  end
end
