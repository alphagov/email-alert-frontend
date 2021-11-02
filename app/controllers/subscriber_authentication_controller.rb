class SubscriberAuthenticationController < ApplicationController
  include GovukPersonalisation::ControllerConcern
  include AccountHelper
  include SessionsHelper

  def sign_in
    @address = params[:address]
  end

  def verify
    if params[:address].blank?
      flash.now[:error] = :missing_email
      return render :sign_in
    end

    @address = params.require(:address)
    case VerifySubscriberEmailService.call(@address, govuk_account_session: account_session_header)
    when :account
      redirect_with_analytics process_govuk_account_path
    when :account_reauthenticate
      logout!
      render :use_your_govuk_account
    else
      render :check_email
    end
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:error] = :invalid_email
    render :sign_in
  rescue VerifySubscriberEmailService::RatelimitExceededError
    head :too_many_requests
  rescue GdsApi::HTTPNotFound
    render :no_subscriber, email: @address
  end

  def process_sign_in_token
    unless token.valid?
      deauthenticate_subscriber
      flash[:error] = :bad_token
      return redirect_to :sign_in
    end

    authenticate_subscriber(token.data[:subscriber_id])
    redirect_to list_subscriptions_path
  end

  def process_govuk_account
    head :not_found and return unless govuk_account_auth_enabled?
    reauthenticate_govuk_account and return if account_session_header.blank?

    api_response = GdsApi.email_alert_api.link_subscriber_to_govuk_account(govuk_account_session: account_session_header)
    set_account_session_header(api_response["govuk_account_session"])
    authenticate_subscriber(api_response.dig("subscriber", "id"), linked_to_govuk_account: true)
    redirect_to list_subscriptions_path
  rescue GdsApi::HTTPUnauthorized, GdsApi::HTTPForbidden
    reauthenticate_govuk_account
  end

private

  def token
    @token ||= AuthToken.new(params.require(:token))
  end

  def reauthenticate_govuk_account
    deauthenticate_subscriber
    logout!

    redirect_with_analytics GdsApi.account_api.get_sign_in_url(redirect_path: process_govuk_account_path)["auth_uri"]
  end
end
