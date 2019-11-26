class SubscriptionAuthenticationController < ApplicationController
  def authenticate
    @topic_id = params.require(:topic_id)
    @frequency = params.require(:frequency)

    unless token_valid?
      render :expired
      return
    end

    address = token[:address]

    subscriber_list_id = email_alert_api
      .get_subscriber_list(slug: @topic_id)
      .dig("subscriber_list", "id")

    email_alert_api.subscribe(
      subscriber_list_id: subscriber_list_id,
      address: address,
      frequency: @frequency,
    )

    redirect_to subscription_path(topic_id: @topic_id, frequency: @frequency)
  end

private

  def token
    @token ||= read_token
  end

  def token_valid?
    return false unless token
    token[:topic_id] == @topic_id
  end

  def read_token
    payload, = JWT.decode(params.require(:token), secret, true, algorithm: "HS256")
    payload.fetch("data").to_h.symbolize_keys
  rescue JWT::DecodeError
    nil
  end

  def secret
    Rails.application.secrets.email_alert_auth_token
  end

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api_with_no_caching)
  end
end
