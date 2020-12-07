class UnsubscriptionsController < ApplicationController
  before_action :set_attributes
  before_action :check_is_latest, only: %i[confirm]

  def confirm
    if subscription_ended?(@subscription)
      render :confirm_already_unsubscribed
    else
      render :confirm
    end
  end

  def confirmed
    unsubscribed = begin
                     GdsApi.email_alert_api.unsubscribe(@id)
                   rescue GdsApi::HTTPNotFound
                     # The user has already unsubscribed.
                     nil
                   end

    if authenticated?
      if unsubscribed
        flash[:success] = {
          message: t("subscriptions_management.index.unsubscribe.message", title: @title),
          description: t("subscriptions_management.index.unsubscribe.description"),
        }
      end

      redirect_to list_subscriptions_path
    end
  end

private

  def set_attributes
    @id = params.require(:id)
    @subscription = GdsApi.email_alert_api.get_subscription(@id)
    @title = @subscription.dig("subscription", "subscriber_list", "title")
  end

  def check_is_latest
    latest_subscription_id = GdsApi
      .email_alert_api
      .get_latest_matching_subscription(@id)
      .dig("subscription", "id")

    return if latest_subscription_id == @subscription.dig("subscription", "id")

    redirect_to confirm_unsubscribe_path(latest_subscription_id)
  end

  def subscription_ended?(subscription)
    subscription.dig("subscription", "ended_at").present?
  end
end
