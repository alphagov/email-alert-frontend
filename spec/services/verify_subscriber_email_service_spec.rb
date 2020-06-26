RSpec.describe VerifySubscriberEmailService do
  include GdsApi::TestHelpers::EmailAlertApi

  describe ".call" do
    let(:address) { "foo@bar.com" }
    let(:rate_limiter) { instance_double(Ratelimit, add: nil, exceeded?: false) }

    let!(:request) do
      stub_email_alert_api_sends_subscriber_verification_email("id", address)
    end

    before do
      allow(Ratelimit).to receive(:new).and_return(rate_limiter)
    end

    it "makes an API call to send a verification email" do
      described_class.call(address)
      expect(request).to have_been_requested
    end

    it "hides whether or not a user is subscribed" do
      stub_email_alert_api_subscriber_verification_email_no_subscriber
      expect { described_class.call(address) }.to_not raise_error
    end

    it "increments a rate limiter for the address" do
      expect(rate_limiter).to receive(:add).with(address)
      described_class.call(address)
    end

    it "raises an error for too many requests per minute" do
      allow(rate_limiter).to receive(:exceeded?).with(
        address,
        threshold: described_class::MINUTELY_THRESHOLD,
        interval: 60.seconds.to_i,
      ).and_return(true)

      expect { described_class.call(address) }
        .to raise_error(described_class::RatelimitExceededError)
    end

    it "raises an error for too many requests per minute" do
      allow(rate_limiter).to receive(:exceeded?).with(
        address,
        threshold: described_class::HOURLY_THRESHOLD,
        interval: 1.hour.to_i,
      ).and_return(true)

      expect { described_class.call(address) }
        .to raise_error(described_class::RatelimitExceededError)
    end
  end
end
