class SubscriptionsController < ApplicationController
  before_action :assign_attributes
  before_action :assign_back_url

  MISSING_EMAIL_ERROR = "Please enter your email address.".freeze
  INVALID_EMAIL_ERROR = "This doesn’t look like a valid email address – check you’ve entered it correctly.".freeze

  def new
    if @frequency.present?
      return frequency_form_redirect unless valid_frequency
      render :new_address
    else
      render :new_frequency
    end
  end

  def frequency
    return frequency_form_redirect unless valid_frequency

    redirect_to new_subscription_path(
      topic_id: @topic_id,
      frequency: @frequency,
    )
  end

  def create
    return frequency_form_redirect unless valid_frequency

    if @address.present? && subscribe
      redirect_to subscription_path(topic_id: @topic_id, frequency: @frequency)
    else
      flash.now[:error] = @address.present? ? INVALID_EMAIL_ERROR : MISSING_EMAIL_ERROR

      render :new_address
    end
  end

  def complete; end

private

  def assign_attributes
    @topic_id = subscription_params.require(:topic_id)
    @subscribable = email_alert_api
      .get_subscribable(reference: @topic_id)
      .to_h.fetch("subscribable")
    @frequency = subscription_params[:frequency]
    @address = subscription_params[:address]
    @title = @subscribable["title"]
  end

  def assign_back_url
    @back_url = url_for(action: :new, topic_id: @topic_id)
    @back_url = govuk_url if params[:action] == "new" && !@frequency.present?
  end

  def subscription_params
    params.permit(:topic_id, :address, :frequency)
  end

  def valid_frequency
    %w[immediately daily weekly].include?(@frequency)
  end

  def frequency_form_redirect
    redirect_to new_subscription_path(topic_id: @topic_id)
  end

  def govuk_url
    referer = request.referer

    if referer && referer.exclude?("/email/subscriptions")
      referer_uri = URI(referer)
      sanitised_referer_uri = Plek.new.website_uri
      sanitised_referer_uri.path = referer_uri.path
      sanitised_referer_uri.query = referer_uri.query
      sanitised_referer_uri.fragment = referer_uri.fragment
      sanitised_referer_uri.to_s
    else
      Plek.new.website_root
    end
  end

  def subscribe
    email_alert_api.subscribe(
      subscribable_id: @subscribable["id"],
      address: @address,
      frequency: @frequency,
    )
  rescue GdsApi::HTTPUnprocessableEntity
    false
  end

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api)
  end
end
