class SubscriptionsController < ApplicationController
  include FrequenciesHelper
  before_action :assign_attributes

  def new
    @back_url = @frequency.blank? ? govuk_url : url_for(action: :new, topic_id: @topic_id)
    if @frequency.present?
      return frequency_form_redirect unless valid_frequency

      render :new_address
    else
      render :new_frequency
    end
  end

  def frequency
    if @frequency.present?
      return frequency_form_redirect unless valid_frequency

      redirect_to new_subscription_path(
        topic_id: @topic_id,
        frequency: @frequency,
      )
    else
      flash.now[:error] = t("subscriptions.new_frequency.missing_frequency")
      @back_url = url_for(action: :new, topic_id: @topic_id)
      render :new_frequency
    end
  end

  def verify
    return frequency_form_redirect unless valid_frequency

    @back_url = url_for(
      host: Plek.new.website_root,
      action: :new,
      topic_id: @topic_id,
      frequency: @frequency,
      address: @address,
    )

    if @address.present?
      VerifySubscriptionEmailService.call(@address, @frequency, @topic_id)
      render :check_email
    else
      flash.now[:error] = t("subscriptions.new_address.missing_email")
      render :new_address
    end
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:error] = t("subscriptions.new_address.invalid_email")
    render :new_address
  rescue VerifySubscriptionEmailService::RatelimitExceededError
    head :too_many_requests
  end

private

  def assign_attributes
    @topic_id = subscription_params.require(:topic_id)
    @subscriber_list = GdsApi.email_alert_api
      .get_subscriber_list(slug: @topic_id)
      .to_h.fetch("subscriber_list")
    @frequency = subscription_params[:frequency]
    @address = subscription_params[:address]
    @title = @subscriber_list["title"]
  end

  def subscription_params
    params.permit(:topic_id, :address, :frequency)
  end

  def valid_frequency
    valid_frequencies.include?(@frequency)
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
    elsif @subscriber_list["url"]&.match?(%r{^/get-ready-brexit-check/results})
      (Plek.new.website_root + @subscriber_list["url"]).to_s
    else
      Plek.new.website_root
    end
  end
end
