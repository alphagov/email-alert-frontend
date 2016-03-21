require 'active_model'

class EmailAlertSignup
  include ActiveModel::Model

  validates_presence_of :signup_page

  delegate :title, to: :signup_page
  delegate :summary, :govdelivery_title, to: :"signup_page.details"

  attr_reader :subscription_url

  def initialize(signup_page)
    @signup_page = signup_page
    @base_path = signup_page.base_path if signup_page
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
  attr_reader :signup_page, :base_path

  def subscription_params
    subscriber_list = signup_page.details.subscriber_list

    subscription_params = {
      title: govdelivery_title.present? ? govdelivery_title : title
    }

    if subscriber_list.document_type.present?
      subscription_params[:document_type] = subscriber_list.document_type
    end

    if subscriber_list.tags.present?
      subscription_params[:tags] = subscriber_list.tags.to_h
    end

    if subscriber_list.links.present?
      subscription_params[:links] = subscriber_list.links.to_h
    end

    subscription_params.deep_stringify_keys
  end

  def raw_breadcrumbs
    if signup_page.details.breadcrumbs
      signup_page.details.breadcrumbs.map(&method(:openstruct_to_hash))
    end
  end

  def openstruct_to_hash(openstruct)
    openstruct.marshal_dump
  end
end
