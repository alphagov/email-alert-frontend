RSpec.describe VerifySubscriptionEmailService do
  include GdsApi::TestHelpers::EmailAlertApi

  describe ".call" do
    let(:address) { "foo@bar.com" }
    let(:frequency) { "immediately" }
    let(:topic_id) { "topic_id" }

    it "makes an API call to send a verification email" do
      request = stub_email_alert_api_sends_subscription_verification_email(address, frequency, topic_id)
      described_class.call(address: address, frequency: frequency, topic_id: topic_id)
      expect(request).to have_been_requested
    end
  end
end
