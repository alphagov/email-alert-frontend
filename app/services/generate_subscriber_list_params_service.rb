class GenerateSubscriberListParamsService < ApplicationService
  def initialize(content_item, single_page = nil)
    super()
    @content_item = content_item
    @single_page = single_page
  end

  def call
    return attributes_for_content_id_based_lists if single_page

    attributes_for_links_based_lists
  end

private

  attr_reader :content_item, :single_page

  class UnsupportedContentItemError < StandardError; end

  def attributes_for_links_based_lists
    {
      "title" => content_item["title"],
      "links" => link_hash,
      "url" => content_item["base_path"],
    }
  end

  def attributes_for_content_id_based_lists
    {
      "title" => content_item["title"],
      "content_id" => content_item["content_id"],
      "url" => content_item["base_path"],
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
    content_item["document_type"]
  end
end
