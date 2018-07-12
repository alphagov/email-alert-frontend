class AuthenticationController < ApplicationController
  MISSING_EMAIL_ERROR = 'Please enter your email address.'.freeze
  INVALID_EMAIL_ERROR = 'This doesn’t look like a valid email address – check you’ve entered it correctly.'.freeze

  def sign_in
    @address = params[:address]
  end

  def request_sign_in_token
    unless params[:address].present?
      flash.now[:error] = MISSING_EMAIL_ERROR
      flash.now[:error_summary] = "email"
      return render :sign_in
    end

    @address = params.require(:address)

    email_alert_api.create_auth_token(
      address: @address,
      destination: process_sign_in_token_path
    )
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:error] = INVALID_EMAIL_ERROR
    flash.now[:error_summary] = "email"
    render :sign_in
  rescue GdsApi::HTTPNotFound
    # User isn't subscribed, but we carry on as if they were so we
    # don't reveal this information.
    nil
  end

  def process_sign_in_token
    subscriber_id, redirect = read_token(params.require(:token))

    if subscriber_id.nil?
      deauthenticate_subscriber
      flash[:error_summary] = "bad_token"
      return redirect_to :sign_in
    end

    authenticate_subscriber(subscriber_id)

    destination = safe_redirect_destination(redirect) || list_subscriptions_path
    redirect_to destination
  end

private

  def read_token(token)
    payload, = JWT.decode(token, secret, true, algorithm: 'HS256')
    data = payload.fetch('data')
    subscriber_id = data.fetch('subscriber_id')
    redirect = data.fetch('redirect')
    [subscriber_id, redirect]
  rescue JWT::ExpiredSignature, JWT::VerificationError, KeyError
    []
  end

  def authenticate_subscriber(subscriber_id)
    session['authentication'] = {
      'subscriber_id' => subscriber_id
    }
  end

  def deauthenticate_subscriber
    session['authentication'] = nil
  end

  def safe_redirect_destination(redirect)
    return nil unless redirect
    parsed = URI.parse(redirect)
    redirect if parsed.relative? && redirect[0] == '/'
  rescue URI::InvalidURIError
    nil
  end

  def secret
    Rails.application.secrets.email_alert_auth_token
  end

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api_with_no_caching)
  end
end
