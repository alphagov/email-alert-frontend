describe SubscriptionsHelper do
  include GdsApi::TestHelpers::ContentStore

  describe "#get_updated_at_from_subscription" do
    let(:url) { "/some-page" }
    let(:subscription) do
      {
        "id" => 12_345,
        "subscriber_list" => {
          "id" => "abc123",
          "url" => url,
        },
      }
    end

    before do
      stub_content_store_has_item(url)
    end

    it "gets the last updated date from the content store" do
      updated = get_updated_at_from_subscription(subscription)
      expect(updated).to eq("2014-05-06T12:01:00+00:00")
    end
  end

  describe "#get_heading_content" do
    let(:subscription) do
      {
        "id" => 12_345,
        "subscriber_list" => {
          "id" => "abc123",
          "title" => "A list title",
        },
      }
    end
    it "returns the list title for a topic subscription" do
      result = get_heading_content(subscription)
      expect(result).to eq("A list title")
    end

    context "when the subscription is for a single page" do
      let(:subscription) do
        {
          "id" => 12_345,
          "subscriber_list" => {
            "id" => "abc123",
            "title" => "A single page subscription",
            "content_id" => "def456",
            "url" => "/a-single-page",
          },
        }
      end

      it "returns a link to the page" do
        result = get_heading_content(subscription)
        expect(result).to include('href="/a-single-page"')
        expect(result).to include("A single page subscription")
      end
    end
  end
end
