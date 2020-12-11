RSpec.describe GenerateSubscriberListParamsService do
  describe ".call" do
    let(:content_item) do
      { "title" => "Foo", "content_id" => "foo-id", "base_path" => "/foo" }
    end

    let(:list_params) do
      { "title" => content_item["title"], "url" => content_item["base_path"] }
    end

    it "returns subscriber list params for taxons" do
      content_item.merge!("document_type" => "taxon")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "taxon_tree" => %w[foo-id] }))
    end

    it "returns subscriber list params for organisations" do
      content_item.merge!("document_type" => "organisation")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "organisations" => %w[foo-id] }))
    end

    it "returns subscriber list params for people" do
      content_item.merge!("document_type" => "person")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "people" => %w[foo-id] }))
    end

    it "returns subscriber list params for ministerial roles" do
      content_item.merge!("document_type" => "ministerial_role")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "roles" => %w[foo-id] }))
    end

    it "returns subscriber list params for topical events" do
      content_item.merge!("document_type" => "topical_event")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "topical_events" => %w[foo-id] }))
    end

    it "returns subscriber list params for topics" do
      content_item.merge!("document_type" => "topic")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "topics" => %w[foo-id] }))
    end

    it "returns subscriber list params for service manual topics" do
      content_item.merge!("document_type" => "service_manual_topic")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "service_manual_topics" => %w[foo-id] }))
    end

    it "returns subscriber list params for the service standard" do
      content_item.merge!("document_type" => "service_manual_service_standard")

      expect(described_class.call(content_item))
        .to match(list_params.merge("links" => { "parent" => %w[foo-id] }))
    end

    it "raises an error when the document type is not supported" do
      content_item.merge!("document_type" => "other")

      expect { described_class.call(content_item) }
        .to raise_error GenerateSubscriberListParamsService::UnsupportedContentItemError
    end
  end
end
