class UnsubscriptionsController < ApplicationController
  before_action :set_cache_control_header
  before_action :set_title, :set_uuid

  def confirm; end

  def confirmed
    api.unsubscribe(@uuid)
  rescue GdsApi::HTTPNotFound
    # The user has already unsubscribed.
    nil
  end

private

  def set_cache_control_header
    headers["Cache-Control"] = "private"
  end

  def set_title
    @title = params[:title].presence
  end

  def set_uuid
    @uuid = params[:uuid].presence
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
