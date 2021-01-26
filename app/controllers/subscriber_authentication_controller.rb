class SubscriberAuthenticationController < ApplicationController
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

private

  def token
    @token ||= AuthToken.new(params.require(:token))
  end
end
