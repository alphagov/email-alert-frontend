class UnsubscriptionsController < ApplicationController
  before_action :set_title, :set_uuid, :set_back_url, :set_from

  def confirm; end

  def confirmed
    api.unsubscribe(@uuid)
  rescue GdsApi::HTTPNotFound
    # The user has already unsubscribed.
    nil
  end

private

  def set_title
    @title = params[:title].presence
  end

  def set_uuid
    @uuid = params[:uuid].presence
  end

  def set_back_url
    @back_url = list_subscriptions_path
  end

  def set_from
    @from = from
    @from_subscription_management = from_subscription_management?
  end

  def from
    params.permit(:from).fetch(:from, "")
  end

  def from_subscription_management?
    from == "subscription-management"
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
