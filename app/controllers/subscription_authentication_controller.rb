class SubscriptionAuthenticationController < ApplicationController
  include FrequenciesHelper

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

    subscriber_list_id = GdsApi.email_alert_api
      .get_subscriber_list(slug: @topic_id)
      .dig("subscriber_list", "id")

    GdsApi.email_alert_api.subscribe(
      subscriber_list_id: subscriber_list_id,
      address: token.data[:address],
      frequency: @frequency,
    )

    redirect_to subscription_complete_path(topic_id: @topic_id, frequency: @frequency)
  end

  def complete
    topic_id = params.require(:topic_id)
    @frequency = params.require(:frequency)

    @title = GdsApi.email_alert_api
      .get_subscriber_list(slug: topic_id)
      .to_h.dig("subscriber_list", "title")
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
