class VerifySubscriptionEmailService < ApplicationService
  class RatelimitExceededError < StandardError; end

  # This allows for up to 2 retries, to account for users
  # not getting the email quickly enough and resubmitting,
  # and for users who subscribe to several things quickly.
  MINUTELY_THRESHOLD = 4

  # This allows for up to 10 subscriptions per hour. Analysis
  # shows 99% of subscribers have 10 or fewer active subs,
  # so this covers someone creating all their subs in bulk.
  HOURLY_THRESHOLD = 11

  def initialize(address, frequency, topic_id)
    @topic_id = topic_id
    @address = address
    @frequency = frequency
  end

  def call
    rate_limiter.add(address)
    raise_if_over_rate_limit

    email_alert_api.send_subscription_verification_email(
      topic_id: topic_id,
      address: address,
      frequency: frequency,
    )
  end

private

  attr_reader :topic_id, :address, :frequency

  def raise_if_over_rate_limit
    raise RatelimitExceededError if rate_limiter.exceeded?(
      address,
      threshold: MINUTELY_THRESHOLD,
      interval: 1.minute.to_i,
    )

    raise RatelimitExceededError if rate_limiter.exceeded?(
      address,
      threshold: HOURLY_THRESHOLD,
      interval: 1.hour.to_i,
    )
  end

  def rate_limiter
    @rate_limiter ||= Ratelimit.new("email-alert-frontend:verify-subscription")
  end

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
