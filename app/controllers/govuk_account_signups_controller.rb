class GovukAccountSignupsController < ApplicationController
  include GovukPersonalisation::ControllerConcern

  UNSUBSCRIBE_FLASH = "email-unsubscribe-success".freeze
  DEFAULT_FREQUENCY = "immediately".freeze

  skip_forgery_protection only: [:create]
  before_action :validate_base_path, only: %i[create]
  before_action :fetch_subscriber_list, only: %i[create]
  before_action :not_found_without_topic_id, only: %i[edit show]

  def show; end

  def create
    unless logged_in?
      redirect_to new_govuk_account_signup_path(topic_id: @topic_id) and return
    end

    subscriber = GdsApi.email_alert_api.authenticate_subscriber_by_govuk_account(
      govuk_account_session: @account_session_header,
    ).to_h.fetch("subscriber")

    subscriptions = GdsApi.email_alert_api.get_subscriptions(id: subscriber.fetch("id")).to_h.fetch("subscriptions", [])

    subscription = subscriptions.find { |s| s["subscriber_list"]["id"] == @subscriber_list["id"] }

    if subscription
      GdsApi.email_alert_api.unsubscribe(subscription["id"])
      account_flash_add UNSUBSCRIBE_FLASH
    else
      result = CreateAccountSubscriptionService.call(@subscriber_list, DEFAULT_FREQUENCY, @account_session_header)
      account_flash_add CreateAccountSubscriptionService::SUCCESS_FLASH
      set_account_session_header(result[:govuk_account_session])
    end

    redirect_to @content_item.fetch("base_path")
  rescue GdsApi::HTTPUnauthorized
    logout!
    sign_in_and_confirm(@topic_id)
  end

  def edit
    sign_in_and_confirm(topic_id)
  end

private

  def not_found_without_topic_id
    head :not_found and return unless topic_id
  end

  def topic_id
    @topic_id = params[:topic_id]
  end

  def validate_base_path
    URI.parse(params.fetch(:base_path))
  rescue URI::InvalidURIError => e
    Rails.logger.warn("Bad base path passed to SinglePageSubscriptionsController: #{e}")
    head :unprocessable_content
  end

  def fetch_subscriber_list
    @content_item = GdsApi.content_store.content_item(params.fetch(:base_path)).to_h
    @subscriber_list =
      GdsApi.email_alert_api
      .find_or_create_subscriber_list(list_params)
      .to_h
      .fetch("subscriber_list")
    @topic_id = @subscriber_list.fetch("slug")
  end

  def list_params
    @list_params ||= SubscriberListParams::GenerateSinglePageListParamsService.call(@content_item.to_h)
  end

  def sign_in_and_confirm(topic_id)
    redirect_with_analytics GdsApi.account_api.get_sign_in_url(
      redirect_path: confirm_account_subscription_path(topic_id:, return_to_url: true, frequency: DEFAULT_FREQUENCY),
    )["auth_uri"]
  end
end
