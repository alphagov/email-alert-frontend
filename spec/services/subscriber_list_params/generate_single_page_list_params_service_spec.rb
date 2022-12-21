RSpec.describe SubscriberListParams::GenerateSinglePageListParamsService do
  describe ".call" do
    let(:content_item) do
      { "base_path" => "/foo",
        "title" => "Foo",
        "content_id" => "foo-id",
        "description" => "foo-info" }
    end

    let(:list_params) do
      {
        "url" => content_item["base_path"],
        "title" => content_item["title"],
        "content_id" => content_item["content_id"],
        "description" => content_item["description"],
      }
    end

    it "returns subscriber list params for single page subscriptions" do
      expect(described_class.call(content_item)).to match(list_params)
    end

    context "content is a document collection" do
      it "adds a reverse link to the params" do
        content_item.merge!("document_type" => "document_collection")
        expected_list_params = list_params.merge("links" => { "document_collections" => %w[foo-id] })

        expect(described_class.call(content_item)).to match(expected_list_params)
      end
    end
  end
end
