module SubscriberListParams
  class GenerateSinglePageListParamsService < ApplicationService
    DOCUMENT_TYPES_WITH_REVERSE_LINKED_LISTS = { "document_collection" => "document_collections" }.freeze

    def initialize(content_item)
      super()
      @content_item = content_item
    end

    def call
      {
        "url" => content_item["base_path"],
        "title" => content_item["title"],
        "content_id" => content_item["content_id"],
        "description" => content_item["description"],
      }.merge(links)
    end

  private

    attr_reader :content_item

    def links
      return {} unless reverse_linked_key

      { "links" => reverse_links }
    end

    def reverse_links
      { reverse_linked_key => [content_item["content_id"]] }
    end

    def reverse_linked_key
      DOCUMENT_TYPES_WITH_REVERSE_LINKED_LISTS[document_type]
    end

    def document_type
      content_item["document_type"]
    end
  end
end
