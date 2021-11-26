# frozen_string_literal: true

class AccountSubscriptionsController < ApplicationController
  include FrequenciesHelper
  include GovukPersonalisation::ControllerConcern

  DEFAULT_FREQUENCY = "daily"

  before_action do
    @topic_id = subscription_parameters.fetch(:topic_id)
    @subscriber_list = GdsApi.email_alert_api.get_subscriber_list(slug: @topic_id).to_h.fetch("subscriber_list")
    @frequency = subscription_parameters.fetch(:frequency, DEFAULT_FREQUENCY)
    @return_to_url = params[:return_to_url]

    unless valid_frequencies.include?(@frequency)
      redirect_with_analytics confirm_account_subscription_path(
        topic_id: @topic_id,
        return_to_url: @return_to_url,
      )
    end
  end

  rescue_from GdsApi::HTTPUnauthorized, with: :reauthenticate_user
  rescue_from GdsApi::HTTPForbidden, with: :reauthenticate_user

  def confirm
    reauthenticate_user and return unless logged_in?

    response = GdsApi.email_alert_api.authenticate_subscriber_by_govuk_account(
      govuk_account_session: account_session_header,
    )
    set_account_session_header(response["govuk_account_session"])
    subscriber = response.to_h.fetch("subscriber")

    @address = subscriber.fetch("address")

    @unlinked_subscriptions =
      if subscriber["govuk_account_id"]
        []
      else
        GdsApi.email_alert_api.get_subscriptions(id: subscriber.fetch("id")).to_h.fetch("subscriptions", [])
      end
  end

  def create
    result = CreateAccountSubscriptionService.call(@subscriber_list, @frequency, account_session_header)
    reauthenticate_user and return unless result

    set_account_session_header(result[:govuk_account_session])

    if @return_to_url.blank? || @subscriber_list["url"].blank?
      flash[:subscription] = { id: result[:subscription]["id"] }
      redirect_to list_subscriptions_path
    else
      account_flash_add CreateAccountSubscriptionService::SUCCESS_FLASH
      redirect_to @subscriber_list["url"]
    end
  end

private

  def subscription_parameters
    params.permit(:topic_id, :frequency, :return_to_url)
  end

  def reauthenticate_user
    logout!

    redirect_with_analytics GdsApi.account_api.get_sign_in_url(
      redirect_path: confirm_account_subscription_path(
        topic_id: @topic_id,
        frequency: @frequency,
        return_to_url: @return_to_url,
      ),
    )["auth_uri"]
  end
end
