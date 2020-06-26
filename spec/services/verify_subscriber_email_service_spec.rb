RSpec.describe VerifySubscriberEmailService do
  include GdsApi::TestHelpers::EmailAlertApi

  describe ".call" do
    let(:address) { "foo@bar.com" }

    it "makes an API call to send a verification email" do
      request = stub_email_alert_api_sends_subscriber_verification_email("id", address)
      described_class.call(address: address)
      expect(request).to have_been_requested
    end

    it "hides whether or not a user is subscribed" do
      stub_email_alert_api_subscriber_verification_email_no_subscriber
      expect { described_class.call(address: address) }.to_not raise_error
    end
  end
end
