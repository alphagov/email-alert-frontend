class SubscriberAuthenticationController < ApplicationController
  def sign_in
    @address = params[:address]
  end

  def request_sign_in_token
    if params[:address].blank?
      flash.now[:error] = t("subscriber_authentication.sign_in.missing_email")
      flash.now[:error_summary] = "email"
      return render :sign_in
    end

    @address = params.require(:address)
    VerifySubscriberEmailService.call(@address)
  rescue GdsApi::HTTPUnprocessableEntity
    flash.now[:error] = t("subscriber_authentication.sign_in.invalid_email")
    flash.now[:error_summary] = "email"
    render :sign_in
  rescue VerifySubscriberEmailService::RatelimitExceededError
    head :too_many_requests
  end

  def process_sign_in_token
    unless token.valid?
      deauthenticate_subscriber
      flash[:error_summary] = "bad_token"
      return redirect_to :sign_in
    end

    authenticate_subscriber(token.data[:subscriber_id])
    redirect_to list_subscriptions_path
  end

private

  def token
    @token ||= AuthToken.new(params.require(:token))
  end

  def authenticate_subscriber(subscriber_id)
    session["authentication"] = {
      "subscriber_id" => subscriber_id,
    }
  end

  def deauthenticate_subscriber
    session["authentication"] = nil
  end
end
