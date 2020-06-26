class VerifySubscriptionEmailService < ApplicationService
  def initialize(topic_id:, address:, frequency:)
    @topic_id = topic_id
    @address = address
    @frequency = frequency
  end

  def call
    email_alert_api.send_subscription_verification_email(
      topic_id: @topic_id,
      address: @address,
      frequency: @frequency,
    )
  end

private

  attr_reader :topic_id, :address, :frequency

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
