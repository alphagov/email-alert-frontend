require 'rails_helper'

RSpec.describe TaxonomySignup do
  describe "#save" do
    let(:mock_email_alert_api) do
      instance_double(EmailAlertFrontend.services(:email_alert_api).class)
    end

    let(:fake_taxon) { { 'title' => 'Foo', 'content_id' => 'foo-id' } }

    before do
      allow(EmailAlertFrontend)
        .to receive(:services)
        .with(:email_alert_api)
        .and_return(mock_email_alert_api)
      allow(mock_email_alert_api)
        .to receive(:find_or_create_subscriber_list)
        .and_return('subscriber_list' => { 'subscription_url' => '/something' })
    end

    it 'asks email-alert-api to find or create a subscriber list' do
      signup = TaxonomySignup.new(fake_taxon)

      expect(signup.save).to be
      expect(mock_email_alert_api)
        .to have_received(:find_or_create_subscriber_list)
        .with('title' => 'Foo', 'links' => { 'taxon_tree' => ['foo-id'] })
    end

    it 'sets the subscription management url' do
      signup = TaxonomySignup.new(fake_taxon)

      expect(signup.save).to be
      expect(signup.subscription_management_url).to eq '/something'
    end

    context 'when no taxon present' do
      it 'does nothing' do
        signup = TaxonomySignup.new(nil)

        expect(signup.save).to_not be
        expect(mock_email_alert_api).to_not have_received(:find_or_create_subscriber_list)
        expect(signup.subscription_management_url).to eq nil
      end
    end
  end
end
