class SubscriptionsController < ApplicationController
  include FrequenciesHelper
  before_action :assign_attributes

  def new
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
      render :new_frequency
    end
  end

  def verify
    return frequency_form_redirect unless valid_frequency

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
end
