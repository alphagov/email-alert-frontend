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
    {
      title: govdelivery_title.present? ? govdelivery_title : title,
      tags: construct_tags_payload_for_alert_api,
      links: construct_links_payload_for_alert_api,
    }.deep_stringify_keys
  end

  def construct_tags_payload_for_alert_api
    # FIXME: a (very) temporary conditional check - once govuk-schema changes
    # are deployed for email_alert_signup content items, change the below to
    # safely rely on signup_tags being present.
    if signup_page.details.signup_tags.present?
      signup_page.details.signup_tags.to_h
    else
      signup_page.details.tags.to_h
    end
  end

  def construct_links_payload_for_alert_api
    email_alert_type = signup_page.details.email_alert_type
    parent_id = signup_page.links.parent.first.content_id
    { email_alert_type => [parent_id] }
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
