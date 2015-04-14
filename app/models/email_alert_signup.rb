require 'active_model'

class EmailAlertSignup
  include ActiveModel::Model

  validates_presence_of :content_item

  delegate :title, to: :content_item
  delegate :summary, :tags, to: :"content_item.details"

  attr_reader :subscription_url

  def initialize(content_item)
    @content_item = content_item
  end

  def save
    if valid?
      @subscription_url = find_or_create_subscription.subscriber_list.subscription_url
      true
    else
      false
    end
  end

  def find_or_create_subscription
    EmailAlertFrontend.services(:email_alert_api)
      .find_or_create_subscriber_list(subscription_params)
  end

private
  attr_reader :content_item

  def subscription_params
    {
      title: title,
      tags: tags.marshal_dump
    }.deep_stringify_keys
  end
end
