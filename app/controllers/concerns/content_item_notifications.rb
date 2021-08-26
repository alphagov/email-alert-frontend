module ContentItemNotifications
  extend ActiveSupport::Concern

  def assign_content_item
    # NOTE: the "topic" param has historically appeared in external links
    @content_item_path = params[:topic] || params[:link]

    return bad_request unless @content_item_path.to_s.starts_with?("/")
    return bad_request unless URI.parse(@content_item_path).relative?

    @content_item ||= GdsApi.content_store.content_item(@content_item_path)
  rescue URI::InvalidURIError
    bad_request
  end

  def assign_list_params
    @list_params = GenerateSubscriberListParamsService.call(@content_item.to_h)
  rescue GenerateSubscriberListParamsService::UnsupportedContentItemError
    bad_request
  end
end
