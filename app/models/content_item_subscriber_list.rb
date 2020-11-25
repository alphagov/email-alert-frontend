class ContentItemSubscriberList
  include Rails.application.routes.url_helpers

  def initialize(content_item)
    @content_item = content_item

    @subscriber_list = GdsApi.email_alert_api
      .find_or_create_subscriber_list(subscription_params)
  end

  def subscription_management_url
    slug = subscriber_list.dig("subscriber_list", "slug")
    new_subscription_path(topic_id: slug)
  end

private

  attr_reader :content_item, :subscriber_list

  class UnsupportedContentItemError < StandardError; end

  def subscription_params
    {
      "title" => content_item["title"],
      "links" => link_hash,
    }
  end

  def link_hash
    case content_item_type
    when "taxon"
      single_link(key: "taxon_tree")
    when "topic"
      single_link(key: "topics")
    when "organisation"
      single_link(key: "organisations")
    when "person"
      single_link(key: "people")
    when "ministerial_role"
      single_link(key: "roles")
    when "topical_event"
      single_link(key: "topical_events")
    when "service_manual_topic"
      single_link(key: "service_manual_topics")
    when "service_manual_service_standard"
      single_link(key: "parent")
    else
      raise UnsupportedContentItemError
    end
  end

  def single_link(key:)
    { key => [content_item["content_id"]] }
  end

  def content_item_type
    content_item.dig("document_type")
  end
end
