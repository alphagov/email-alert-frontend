class SubscriptionsController < ApplicationController
  def new
    @topic_id = params[:topic_id]

    api_response = api.get_subscribable(reference: @topic_id).to_h
    subscribable = api_response["subscribable"]

    @title = subscribable["title"]
    @subscribable_id = subscribable["id"]
  end

  def create
    redirect_to subscription_path
  end

  def show; end

private

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
