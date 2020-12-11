class UnsubscriptionsController < ApplicationController
  before_action :set_attributes
  before_action :check_owns_subscription
  before_action :check_is_latest, only: %i[confirm]

  def confirm
    if @subscription["ended_at"].present?
      render :confirm_already_unsubscribed
    else
      render :confirm
    end
  end

  def confirmed
    begin
      GdsApi.email_alert_api.unsubscribe(@id)
    rescue GdsApi::HTTPNotFound
      # The user has already unsubscribed.
      nil
    end

    if authenticated?
      flash[:success] = {
        message: t("subscriptions_management.index.unsubscribe.message", title: @title),
        description: t("subscriptions_management.index.unsubscribe.description"),
      }

      redirect_to list_subscriptions_path
    end
  end

private

  def set_attributes
    @id = params.require(:id)
    @subscription = GdsApi.email_alert_api.get_subscription(@id).dig("subscription")
    @title = @subscription.dig("subscriber_list", "title")
  end

  def check_is_latest
    latest_subscription_id = GdsApi
      .email_alert_api
      .get_latest_matching_subscription(@id)
      .dig("subscription", "id")

    return if latest_subscription_id == @subscription["id"]

    redirect_to confirm_unsubscribe_path(latest_subscription_id, token: params[:token])
  end

  def check_owns_subscription
    expected_id = @subscription.dig("subscriber", "id")

    # Check for users who have signed in (have a session)
    return if authenticated? && expected_id == authenticated_subscriber_id

    # Check for users who have a one-click unsubscribe link
    token = AuthToken.new(params[:token].to_s)
    return if token.valid? && token.data[:subscriber_id] == expected_id

    flash[:error_summary] = "bad_token" if params[:token]
    redirect_to sign_in_path
  end
end
