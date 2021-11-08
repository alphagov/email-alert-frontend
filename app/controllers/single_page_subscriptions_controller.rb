class SinglePageSubscriptionsController < ApplicationController
  include AccountHelper
  include GovukPersonalisation::ControllerConcern

  UNSUBSCRIBE_FLASH = "email-unsubscribe-success".freeze

  before_action do
    head :not_found unless govuk_account_auth_enabled?
  end

  skip_before_action :verify_authenticity_token, only: [:show]

  def show
    content_item = GdsApi.content_store.content_item(base_path).to_h
    return unless logged_in?

    subscriber = GdsApi.email_alert_api.authenticate_subscriber_by_govuk_account(
      govuk_account_session: @account_session_header,
    ).to_h.fetch("subscriber")

    subscriptions = GdsApi.email_alert_api.get_subscriptions(id: subscriber.fetch("id")).to_h.fetch("subscriptions", [])

    subscriber_list = GdsApi.email_alert_api.find_or_create_subscriber_list(
      {
        url: base_path,
        name: content_item["title"],
        content_id: content_item["content_id"],
      },
    ).to_h.fetch("subscriber_list")

    subscription = subscriptions.find { |s| s["subscriber_list_id"] == subscriber_list["id"] }

    if subscription
      GdsApi.email_alert_api.unsubscribe(subscription["id"])
      account_flash_add UNSUBSCRIBE_FLASH

    else
      result = CreateAccountSubscriptionService.call(subscriber_list, "daily", @account_session_header)
      account_flash_add CreateAccountSubscriptionService::SUCCESS_FLASH
      set_account_session_header(result[:govuk_account_session])
    end

    redirect_to base_path
  rescue GdsApi::ContentStore::ItemNotFound
    head :not_found
  rescue GdsApi::HTTPUnauthorized
    logout!
    redirect_with_analytics single_page_session_path
  end

  def edit
    redirect_with_analytics single_page_session_path
  end

private

  def base_path
    @base_path ||= params.fetch(:base_path)
  end

  def single_page_session_path
    redirect_path = "#{confirm_account_subscription_path}?base_path=#{base_path}"

    GdsApi.account_api.get_sign_in_url(
      redirect_path: redirect_path,
    )["auth_uri"]
  end
end
