RSpec.describe ContentItemSubscriberList do
  describe "#subscription_management_url" do
    let(:mock_email_alert_api) do
      instance_double(EmailAlertFrontend.services(:email_alert_api).class)
    end

    let(:content_item) do
      { "title" => "Foo", "content_id" => "foo-id" }
    end

    before do
      allow(EmailAlertFrontend)
        .to receive(:services)
        .with(:email_alert_api)
        .and_return(mock_email_alert_api)

      allow(mock_email_alert_api)
        .to receive(:find_or_create_subscriber_list)
        .and_return("subscriber_list" => { "subscription_url" => "/something" })
    end

    it "creates a subscriber list for taxons" do
      content_item.merge!("document_type" => "taxon")
      signup = described_class.new(content_item)

      expect(signup.has_content_item?).to be
      expect(signup.subscription_management_url).to eq "/something"

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "taxon_tree" => %w[foo-id] })
    end

    it "does nothing when no content item is present" do
      signup = described_class.new(nil)
      expect(signup.has_content_item?).to_not be
    end

    it "creates a subscriber list for an organisation" do
      content_item.merge!("document_type" => "organisation")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "organisations" => %w[foo-id] })
    end

    it "creates a subscriber list for a person" do
      content_item.merge!("document_type" => "person")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "people" => %w[foo-id] })
    end

    it "creates a subscriber list for a ministerial role" do
      content_item.merge!("document_type" => "ministerial_role")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "roles" => %w[foo-id] })
    end

    it "creates a subscriber list for a topical event" do
      content_item.merge!("document_type" => "topical_event")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "topical_events" => %w[foo-id] })
    end

    it "creates a subscriber list for a service manual topic" do
      content_item.merge!("document_type" => "service_manual_topic")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "service_manual_topics" => %w[foo-id] })
    end

    it "creates a subscriber list for the service standard" do
      content_item.merge!("document_type" => "service_manual_service_standard")
      described_class.new(content_item).subscription_management_url

      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with("title" => "Foo", "links" => { "parent" => %w[foo-id] })
    end
  end
end
