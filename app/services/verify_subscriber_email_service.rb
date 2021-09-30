class VerifySubscriberEmailService < ApplicationService
  include Rails.application.routes.url_helpers

  class RatelimitExceededError < StandardError; end

  # This allows for up to 2 retries, to account for users
  # not getting the email quickly enough and resubmitting.
  MINUTELY_THRESHOLD = 4

  # This allows for up to 10 logins to manage subscriptions
  # per hour, to account # for the user needing to return
  # to manage their # subscriptions on different devices.
  HOURLY_THRESHOLD = 11

  def initialize(address)
    super()
    @address = address
  end

  def call
    rate_limiter.add(address)
    raise_if_over_rate_limit
    GdsApi.email_alert_api.send_subscriber_verification_email(
      address: address,
      destination: process_sign_in_token_path,
    )
  end

private

  attr_reader :address

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
    @rate_limiter ||= Ratelimit.new("email-alert-frontend:verify-subscriber")
  end
end
