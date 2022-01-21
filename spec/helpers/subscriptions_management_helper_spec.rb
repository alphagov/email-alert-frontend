describe SubscriptionsManagementHelper do
  let(:title) { "A subscription list" }
  let(:subscription) do
    {
      "id" => 12_345,
      "subscriber_list" => {
        "id" => "abc123",
        "url" => "/url",
        "title" => title,
      },
    }
  end

  describe "#get_subscription_title" do
    it "gets the title from the subscriber list" do
      subscription_title = get_subscription_title(subscription)
      expect(subscription_title).to eq(title)
    end
  end
end
