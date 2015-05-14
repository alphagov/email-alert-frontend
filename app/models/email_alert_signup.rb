require 'active_model'

class EmailAlertSignup
  include ActiveModel::Model

  validates_presence_of :content_item

  delegate :title, to: :content_item
  delegate :summary, :tags, :govdelivery_title, to: :"content_item.details"

  attr_reader :subscription_url

  def initialize(content_item)
    @content_item = content_item
    @base_path = content_item.base_path if content_item
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

  def breadcrumbs
    return {} if raw_breadcrumbs.blank?

    raw_breadcrumbs.reverse.reduce { |memo, crumb|
      crumb.merge(parent: memo)
    }
  end

  def government?
    base_path.starts_with?("/government")
  end

  def government_content_section
    base_path.split('/')[2]
  end

private
  attr_reader :content_item, :base_path

  def subscription_params
    {
      title: govdelivery_title.present? ? govdelivery_title : title,
      tags: openstruct_to_hash(tags)
    }.deep_stringify_keys
  end

  def raw_breadcrumbs
    if content_item.details.breadcrumbs
      content_item.details.breadcrumbs.map(&method(:openstruct_to_hash))
    end
  end

  def openstruct_to_hash(openstruct)
    openstruct.marshal_dump
  end
end
