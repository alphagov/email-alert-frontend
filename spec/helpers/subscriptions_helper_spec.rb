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
end
