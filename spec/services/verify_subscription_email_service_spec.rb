RSpec.describe VerifySubscriptionEmailService do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi

  describe ".call" do
    let(:address) { "foo@bar.com" }
    let(:args) { [address, "frequency", "topic_id"] }
    let(:rate_limiter) { instance_double(Ratelimit, add: nil, exceeded?: false) }

    let!(:request) do
      stub_email_alert_api_sends_subscription_verification_email(*args)
    end

    before do
      allow(Ratelimit).to receive(:new).and_return(rate_limiter)
    end

    let!(:match_request) do
      stub_account_api_match_user_by_email_does_not_exist(email: address)
    end

    it "raises an error for too many requests per minute" do
      allow(rate_limiter).to receive(:exceeded?).with(
        address,
        threshold: described_class::MINUTELY_THRESHOLD,
        interval: 60.seconds.to_i,
      ).and_return(true)

      expect { described_class.call(*args) }
        .to raise_error(described_class::RatelimitExceededError)
    end

    it "raises an error for too many requests per minute" do
      allow(rate_limiter).to receive(:exceeded?).with(
        address,
        threshold: described_class::HOURLY_THRESHOLD,
        interval: 1.hour.to_i,
      ).and_return(true)

      expect { described_class.call(*args) }
        .to raise_error(described_class::RatelimitExceededError)
    end

    it "makes an API call to check if the address is associated with an account" do
      described_class.call(*args)
      expect(match_request).to have_been_requested
    end

    it "makes an API call to send a verification email" do
      expect(described_class.call(*args)).to eq(:email)
      expect(request).to have_been_requested
    end

    context "the email address is associated with a GOV.UK account" do
      let!(:match_request) do
        stub_account_api_match_user_by_email_does_not_match(email: address)
      end

      it "reauthenticates the user" do
        expect(described_class.call(*args)).to eq(:account_reauthenticate)
      end

      it "does not make an API call to send a verification email" do
        described_class.call(*args)
        expect(match_request).to have_been_requested
        expect(request).not_to have_been_requested
      end

      context "a GOV.UK account session is provided" do
        let(:session_id) { "session-id" }

        it "reauthenticates the user" do
          expect(described_class.call(*args, govuk_account_session: session_id)).to eq(:account_reauthenticate)
        end

        context "the provided session matches the email address" do
          let!(:match_request) do
            stub_account_api_match_user_by_email_matches(email: address)
          end

          it "authenticates the user" do
            expect(described_class.call(*args, govuk_account_session: session_id)).to eq(:account)
          end
        end
      end
    end
  end
end
