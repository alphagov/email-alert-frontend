class UnsubscriptionsController < ApplicationController
  before_action :set_attributes

  def confirm
    return render :confirm_already_unsubscribed if subscription_ended?
  end

  def confirmed
    unsubscribed = begin
                    api.unsubscribe(@id)
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
      flash[:success] = message if unsubscribed
      return redirect_to list_subscriptions_path
    end
  end

private

  def set_attributes
    @id = params.require(:id)
    @subscription = api.get_subscription(@id)
    @title = @subscription.dig("subscription", "subscriber_list", "title").presence
    @authenticated_for_subscription = check_authenticated(@subscription)
  end

  def subscription_ended?
    @subscription.dig("subscription", "ended_at").present?
  end

  def check_authenticated(subscription)
    if authenticated?
      subscriber_id = subscription.dig("subscription", "subscriber", "id")
      subscriber_id == authenticated_subscriber_id
    else
      false
    end
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
