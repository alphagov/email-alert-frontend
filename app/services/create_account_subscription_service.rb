# frozen_string_literal: true

class CreateAccountSubscriptionService < ApplicationService
  SUCCESS_FLASH = "email-subscription-success"

  def initialize(subscriber_list, frequency, govuk_account_session)
    super()
    @subscriber_list = subscriber_list
    @frequency = frequency
    @govuk_account_session = govuk_account_session
  end

  def call
    return false unless @govuk_account_session

    response = GdsApi.email_alert_api.link_subscriber_to_govuk_account(
      govuk_account_session: govuk_account_session,
    )

    subscriber = response.to_h.fetch("subscriber")

    subscription = GdsApi.email_alert_api.subscribe(
      subscriber_list_id: subscriber_list.fetch("id"),
      address: subscriber.fetch("address"),
      frequency: frequency,
    )["subscription"]

    {
      govuk_account_session: response["govuk_account_session"],
      subscription: subscription,
    }
  end

private

  attr_reader :subscriber_list, :frequency, :govuk_account_session
end
