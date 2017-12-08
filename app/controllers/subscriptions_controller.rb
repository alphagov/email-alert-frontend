class SubscriptionsController < ApplicationController
  protect_from_forgery except: [:create]

  with_options only: %i(new create) do
    before_action :assign_topic_id
    before_action :assign_address
    before_action :assign_subscribable
    before_action :assign_title
  end

  def create
    if @address.present? && subscribe
      redirect_to subscription_path
    else
      flash.now[:error] = "Please enter a valid email address."
      render :new
    end
  end

private

  def assign_topic_id
    @topic_id = params.fetch(:topic_id)
  end

  def assign_address
    @address = params[:address]
  end

  def assign_subscribable
    @subscribable = api.get_subscribable(reference: @topic_id).to_h.fetch("subscribable")
  end

  def assign_title
    @title = @subscribable["title"]
  end

  def subscribe
    api.subscribe(subscribable_id: @subscribable["id"], address: @address)
  rescue GdsApi::HTTPUnprocessableEntity
    false
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
