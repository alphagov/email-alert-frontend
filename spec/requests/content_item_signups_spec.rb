RSpec.describe "Content Item Signups" do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  describe "GET /email/subscribe" do
    let(:content_id) { SecureRandom.uuid }
    let(:title) { "Interesting organisation" }
    let(:slug) { "interesting-organisation" }
    let(:base_path) { "/#{slug}" }

    let(:description) { "some info" }
    let(:email_alert_api_response) { { "subscriber_list" => { "slug" => slug } } }

    let(:content_id_based_subscriber_list_params) do
      {
        "url" => base_path,
        "title" => title,
        "content_id" => content_id,
        "description" => "some info",
      }
    end
    let(:find_or_create_link) { "#{GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT}/subscriber-lists" }

    let!(:create_content_id_based_stub) do
      stub_request(:post, find_or_create_link)
        .with(body: hash_including(content_id_based_subscriber_list_params))
        .to_return(status: 200, body: email_alert_api_response.to_json)
    end

    before do
      stub_content_store_has_item(base_path,
                                  content_id:,
                                  document_type: "topical_event",
                                  title:,
                                  base_path:,
                                  description: "some info")
    end

    it "finds or creates content id based subscriber lists for the content" do
      get "/email/subscribe?link=/interesting-organisation"

      expect(create_content_id_based_stub).to have_been_requested
      expect(response).to redirect_to new_subscription_path(topic_id: "interesting-organisation")
    end
  end
end
