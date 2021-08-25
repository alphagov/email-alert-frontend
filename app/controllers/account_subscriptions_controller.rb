class AccountSubscriptionsController < ApplicationController
  include GovukPersonalisation::ControllerConcern
  include AccountHelper
  before_action :enforce_feature_flag
  before_action :assign_content_item
  before_action :assign_list_params

  def new
    @sign_in_or_create_path = logged_in? ? new_account_subscription_path : "/sign-in"
    @auth_status = logged_in? ? "logged_in" : "logged_out"
  end

  def create
    redirect_to(new_account_subscription_path(permitted_parameters)) and return unless logged_in?

    subscriber_list = GdsApi.email_alert_api.find_or_create_subscriber_list(@list_params)["subscriber_list"]
    GdsApi.account_api.put_email_subscription(
      govuk_account_session: @account_session_header,
      name: @content_item["content_id"],
      topic_slug: subscriber_list["slug"],
    )
    redirect_to(@content_item_path)
  end

private

  def permitted_parameters
    params.permit(:link, :topic).to_h
  end

  def sign_in_url
    GdsApi.account_api.get_sign_in_url(
      redirect_path: new_account_subscription_path(permitted_parameters),
      level_of_authentication: "level0",
    ).to_h["auth_uri"]
  end

  def enforce_feature_flag
    head :not_found and return unless govuk_account_auth_enabled?
  end

  def assign_content_item
    # NOTE: the "topic" param has historically appeared in external links
    @content_item_path = params[:topic] || params[:link]

    return bad_request unless @content_item_path.to_s.starts_with?("/")
    return bad_request unless URI.parse(@content_item_path).relative?

    @content_item ||= GdsApi.content_store.content_item(@content_item_path)
  rescue URI::InvalidURIError
    bad_request
  end

  def assign_list_params
    @list_params = GenerateSubscriberListParamsService.call(@content_item.to_h)
  rescue GenerateSubscriberListParamsService::UnsupportedContentItemError
    bad_request
  end
end
