class VerifySubscriptionEmailService < ApplicationService
  class RatelimitExceededError < StandardError; end

  # This allows for up to 2 retries, to account for users
  # not getting the email quickly enough and resubmitting,
  # and for users who subscribe to several things quickly.
  MINUTELY_THRESHOLD = 4

  # This allows for up to 40 subscriptions per hour. The previous threshold of
  # 11 requests per hour seemed too strict as legitimate users hit this limit.
  HOURLY_THRESHOLD = 40

  def initialize(address, frequency, topic_id, govuk_account_session: nil)
    super()
    @topic_id = topic_id
    @address = address
    @frequency = frequency
    @govuk_account_session = govuk_account_session
  end

  def call
    rate_limiter.add(address)
    raise_if_over_rate_limit
    authenticate_with_account
  end

private

  attr_reader :topic_id, :address, :frequency, :govuk_account_session

  def authenticate_with_account
    response = GdsApi.account_api.match_user_by_email(
      email: address,
      govuk_account_session:,
    )

    if response["match"]
      :account
    else
      :account_reauthenticate
    end
  rescue GdsApi::HTTPNotFound
    authenticate_with_email
  end

  def authenticate_with_email
    GdsApi.email_alert_api.send_subscription_verification_email(
      topic_id:,
      address:,
      frequency:,
    )
    :email
  end

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
end
