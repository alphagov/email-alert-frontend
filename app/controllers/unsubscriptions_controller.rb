class UnsubscriptionsController < ApplicationController
  before_action :set_id, :set_title, :set_authenticated

  def confirm; end

  def confirmed
    api.unsubscribe(@id)
  rescue GdsApi::HTTPNotFound
    # The user has already unsubscribed.
    nil
  end

private

  def set_title
    @title = api.get_subscription(@id).dig("subscription", "subscriber_list", "title").presence
  end

  def set_id
    @id = params[:id].presence
  end

  def set_authenticated
    @authenticated = authenticated?
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
