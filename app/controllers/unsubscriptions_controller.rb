class UnsubscriptionsController < ApplicationController
  before_action :set_attributes

  def confirm; end

  def confirmed
    api.unsubscribe(@id)
  rescue GdsApi::HTTPNotFound
    # The user has already unsubscribed.
    nil
  end

private

  def set_attributes
    @id = params.require(:id)
    @subscription = api.get_subscription(@id)
    @title = @subscription.dig("subscription", "subscriber_list", "title").presence
    @authenticated_for_subscription = check_authenticated(@subscription)
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
