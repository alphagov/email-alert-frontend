class SubscriptionsController < ApplicationController
  include AccountHelper
  include FrequenciesHelper
  include GovukPersonalisation::ControllerConcern
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

      result = CreateAccountSubscriptionService.call(@subscriber_list, @frequency, account_session_header)
      if result
        account_flash_add CreateAccountSubscriptionService::SUCCESS_FLASH
        set_account_session_header(result[:govuk_account_session])
        redirect_to process_govuk_account_path
      else
        redirect_to new_subscription_path(
          topic_id: @topic_id,
          frequency: @frequency,
        )
      end
    else
      flash.now[:error] = t("subscriptions.new_frequency.missing_frequency")
      render :new_frequency
    end
  rescue GdsApi::HTTPUnauthorized
    logout!
    redirect_to new_subscription_path(
      topic_id: @topic_id,
      frequency: @frequency,
    )
  end

  def verify
    return frequency_form_redirect unless valid_frequency

    if @address.present?
      if VerifySubscriptionEmailService.call(@address, @frequency, @topic_id, govuk_account_session: account_session_header) == :email
        render :check_email
      else
        logout!
        render :use_your_govuk_account
      end
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

  def verify_account
    head :not_found and return unless govuk_account_auth_enabled?
    return frequency_form_redirect unless valid_frequency

    redirect_with_analytics GdsApi.account_api.get_sign_in_url(
      redirect_path: confirm_account_subscription_path(
        topic_id: @topic_id,
        frequency: @frequency,
      ),
    )["auth_uri"]
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
