class VerifySubscriberEmailService < ApplicationService
  include Rails.application.routes.url_helpers

  class RatelimitExceededError < StandardError; end

  MINUTELY_THRESHOLD = 3 # TODO: update this based on data and comment
  HOURLY_THRESHOLD = 20 # TODO: update this based on data and comment

  def initialize(address)
    @address = address
  end

  def call
    rate_limiter.add(address)
    raise_if_over_rate_limit

    GdsApi.email_alert_api.send_subscriber_verification_email(
      address: address,
      destination: process_sign_in_token_path,
    )
  rescue GdsApi::HTTPNotFound
    # User isn't subscribed, but we carry on as if they were so we
    # don't reveal this information.
    nil
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
