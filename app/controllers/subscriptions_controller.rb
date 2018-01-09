class SubscriptionsController < ApplicationController
  protect_from_forgery except: [:create]

  before_action :assign_topic_id
  before_action :assign_address
  before_action :assign_subscribable
  before_action :assign_title
  before_action :assign_back_url

  def create
    if @address.present? && subscribe
      redirect_to subscription_path(topic_id: @topic_id)
    else
      flash.now[:error] = "This isn’t a valid email address. Check you’ve entered it correctly."
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

  def assign_back_url
    @back_url = url_for(action: :new, topic_id: @topic_id)
    @back_url = govuk_url if params[:action] == "new"
  end

  def govuk_url
    referer = request.referer

    if referer && referer.exclude?("/email/subscriptions")
      referer
    else
      "https://www.gov.uk/"
    end
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
