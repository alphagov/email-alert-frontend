require 'rails_helper'

RSpec.describe ContentItemSubscriberList do
  describe "#subscription_management_url" do
    let(:mock_email_alert_api) do
      instance_double(EmailAlertFrontend.services(:email_alert_api).class)
    end

    let(:fake_taxon) { { 'document_type' => 'taxon', 'title' => 'Foo', 'content_id' => 'foo-id' } }
    let(:fake_organisation) { { 'document_type' => 'organisation', 'title' => 'Org', 'content_id' => 'org-id' } }
    before do
      allow(EmailAlertFrontend)
        .to receive(:services)
        .with(:email_alert_api)
        .and_return(mock_email_alert_api)
      allow(mock_email_alert_api)
        .to receive(:find_or_create_subscriber_list)
        .and_return('subscriber_list' => { 'subscription_url' => '/something' })
    end

    context "given a taxon" do
      it 'asks email-alert-api to find or create a subscriber list' do
        signup = described_class.new(fake_taxon)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq '/something'
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with('title' => 'Foo', 'links' => { 'taxon_tree' => ['foo-id'] })
      end
    end

    context 'when no taxon is present' do
      it 'does nothing' do
        signup = described_class.new(nil)

        expect(signup.has_content_item?).to_not be
      end
    end

    context "given an organisation" do
      it 'asks email-alert-api to find or create a subscriber list' do
        signup = described_class.new(fake_organisation)

        expect(signup.has_content_item?).to be
        expect(signup.subscription_management_url).to eq '/something'
        expect(mock_email_alert_api)
          .to have_received(:find_or_create_subscriber_list)
          .with('title' => 'Org', 'links' => { 'organisations' => ['org-id'] })
      end
    end
  end
end
