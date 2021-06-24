class SubscriberAuthenticationController < ApplicationController
  include GovukPersonalisation::AccountConcern
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
    VerifySubscriberEmailService.call(@address)
    render :check_email
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:error] = :invalid_email
    render :sign_in
  rescue VerifySubscriberEmailService::RatelimitExceededError
    head :too_many_requests
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
    head :not_found and return unless ENV["FEATURE_FLAG_GOVUK_ACCOUNT"] == "enabled"

    api_response = GdsApi.email_alert_api.authenticate_subscriber_by_govuk_account(govuk_account_session: account_session_header)
    set_account_session_header(api_response["govuk_account_session"])
    authenticate_subscriber(api_response.dig("subscriber", "id"))
    redirect_to list_subscriptions_path
  rescue GdsApi::HTTPUnauthorized
    deauthenticate_subscriber
    logout!
    uri = GdsApi.account_api.get_sign_in_url(redirect_path: process_govuk_account_path)["auth_uri"]
    uri += "&_ga=#{params[:_ga]}" if params[:_ga]
    redirect_to uri
  rescue GdsApi::HTTPForbidden => e
    deauthenticate_subscriber
    set_account_session_header(JSON.parse(e.http_body)["govuk_account_session"])
    render plain: "This GOV.UK account does not have a verified email address."
  rescue GdsApi::HTTPNotFound => e
    deauthenticate_subscriber
    set_account_session_header(JSON.parse(e.http_body)["govuk_account_session"])
    render plain: "This GOV.UK account does not have a notifications account."
  end

private

  def token
    @token ||= AuthToken.new(params.require(:token))
  end
end
