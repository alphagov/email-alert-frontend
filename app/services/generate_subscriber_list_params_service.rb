class GenerateSubscriberListParamsService < ApplicationService
  def initialize(content_item)
    @content_item = content_item
  end

  def call
    {
      "title" => content_item["title"],
      "links" => link_hash,
      "url" => content_item["base_path"],
    }
  end

private

  attr_reader :content_item

  class UnsupportedContentItemError < StandardError; end

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
