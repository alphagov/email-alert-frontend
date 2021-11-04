class SinglePageSubscriptionsController < ApplicationController
  include AccountHelper
  include GovukPersonalisation::ControllerConcern

  before_action do
    head :not_found unless govuk_account_auth_enabled?
  end

  skip_before_action :verify_authenticity_token, only: [:show]

  def show
    content_item = GdsApi.content_store.content_item(topic).to_h
    return unless logged_in?

    subscriber_list = GdsApi.email_alert_api.find_or_create_subscriber_list(
      {
        url: topic,
        name: content_item["title"],
        content_id: content_item["content_id"],
      },
    ).to_h.fetch("subscriber_list")

    result = CreateAccountSubscriptionService.call(subscriber_list, "daily", @account_session_header)
    account_flash_add CreateAccountSubscriptionService::SUCCESS_FLASH
    set_account_session_header(result[:govuk_account_session])

    redirect_to topic
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

  def topic
    @topic ||= params.fetch(:topic)
  end

  def single_page_session_path
    redirect_path = "#{confirm_account_subscription_path}?topic=#{topic}"

    GdsApi.account_api.get_sign_in_url(
      redirect_path: redirect_path,
    )["auth_uri"]
  end
end
