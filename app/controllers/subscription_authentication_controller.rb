class SubscriptionAuthenticationController < ApplicationController
  include FrequenciesHelper
  include SessionsHelper

  def authenticate
    @topic_id = params.require(:topic_id)
    @frequency = params.require(:frequency)

    unless token.valid?
      render :expired
      return
    end

    unless valid_params?
      head :unprocessable_entity
      return
    end

    subscriber_list = GdsApi.email_alert_api
      .get_subscriber_list(slug: @topic_id)["subscriber_list"]

    subscription = GdsApi.email_alert_api
      .subscribe(
        subscriber_list_id: subscriber_list["id"],
        address: token.data[:address],
        frequency: @frequency,
      )["subscription"]

    flash[:subscription] = { id: subscription["id"] }

    authenticate_subscriber(subscription.dig("subscriber", "id"))
    redirect_to list_subscriptions_path
  end

private

  def valid_params?
    token.data[:topic_id] == @topic_id &&
      valid_frequencies.include?(@frequency)
  end

  def token
    @token ||= AuthToken.new(params.require(:token))
  end
end
