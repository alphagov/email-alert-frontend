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

    if @authenticated_for_subscription
      message = if @title
                  "You have been unsubscribed from ‘#{@title}’"
                else
                  "You have been unsubscribed"
                end
      description = "It can take up to an hour for this change to take effect."

      if unsubscribed
        flash[:success] = {
          message: message,
          description: description,
        }
      end

      redirect_to list_subscriptions_path
    end
  end

private

  def set_attributes
    @id = params.require(:id)
    @subscription = GdsApi.email_alert_api.get_subscription(@id)
    @title = @subscription.dig("subscription", "subscriber_list", "title").presence
    @authenticated_for_subscription = check_authenticated(@subscription)
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

  def check_authenticated(subscription)
    if authenticated?
      subscriber_id = subscription.dig("subscription", "subscriber", "id")
      subscriber_id == authenticated_subscriber_id
    else
      false
    end
  end
end
