require "rails_helper"

RSpec.describe ContentItemSubscriberList do
  describe "#subscription_management_url" do
    let(:mock_email_alert_api) do
      instance_double(EmailAlertFrontend.services(:email_alert_api).class)
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

    context "given a taxon" do
      it "asks email-alert-api to find or create a subscriber list" do
        taxon = { "document_type" => "taxon", "title" => "Foo",
                  "content_id" => "foo-id", "base_path" => "/taxy/taxon" }

        signup = described_class.new(taxon)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Foo", "links" => { "taxon_tree" => %w[foo-id] })
      end
    end

    context "when no content item is present" do
      it "does nothing" do
        signup = described_class.new(nil)

        expect(signup.has_content_item?).to_not be
      end
    end

    context "given a taxon which is a world_location" do
      it "asks email-alert-api to find or create a subscriber list" do
        world_location = { "document_type" => "taxon", "title" => "Peters Island",
                           "content_id" => "world-id", "base_path" => "/world/peter-island" }

        signup = described_class.new(world_location)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Peters Island", "links" => { "world_locations" => %w[world-id] })
      end
    end

    context "given an organisation" do
      organisation = { "document_type" => "organisation", "title" => "Org", "content_id" => "org-id" }

      it "asks email-alert-api to find or create a subscriber list" do
        signup = described_class.new(organisation)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Org", "links" => { "organisations" => %w[org-id] })
      end
    end

    context "given a person" do
      person = { "document_type" => "person", "title" => "Peter", "content_id" => "person-id" }

      it "asks email-alert-api to find or create a subscriber list" do
        signup = described_class.new(person)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Peter", "links" => { "people" => %w[person-id] })
      end
    end

    context "given a ministerial role" do
      ministerial_role = { "document_type" => "ministerial_role",
                           "title" => "pm", "content_id" => "pm-id" }

      it "asks email-alert-api to find or create a subscriber list" do
        signup = described_class.new(ministerial_role)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "pm", "links" => { "roles" => %w[pm-id] })
      end
    end

    context "given a topical event" do
      topical_event = { "document_type" => "topical_event",
                        "title" => "Summit 2019", "content_id" => "summit-id" }

      it "asks email-alert-api to find or create a subscriber list" do
        signup = described_class.new(topical_event)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Summit 2019", "links" => { "topical_events" => %w[summit-id] })
      end
    end

    context "given a international delegation" do
      international_delegation = { "document_type" => "world_location",
                                   "title" => "Nato Delegation", "content_id" => "delegation-id" }

      it "asks email-alert-api to find or create a subscriber list" do
        signup = described_class.new(international_delegation)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq "/something"
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with("title" => "Nato Delegation", "links" => { "world_locations" => %w[delegation-id] })
      end
    end
  end
end
