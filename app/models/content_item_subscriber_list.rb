class ContentItemSubscriberList
  def initialize(content_item)
    @content_item = content_item
  end

  def subscription_management_url
    subscriber_list.dig('subscriber_list', 'subscription_url')
  end

  def has_content_item?
    content_item.present?
  end

private

  attr_accessor :content_item

  class UnsupportedContentItemError < StandardError; end

  def subscriber_list
    EmailAlertFrontend.services(:email_alert_api)
      .find_or_create_subscriber_list(subscription_params)
  end

  def subscription_params
    {
      'title' => content_item['title'],
      'links' => link_hash
    }
  end

  def link_hash
    case content_item_type
    when 'taxon'
      taxon_links
    else
      message = "No link hash available for content items of type #{content_item_type}!"
      raise UnsupportedContentItemError, message
    end
  end

  def taxon_links
    {
      # 'taxon_tree' is the key used in email-alert-service for
      # notifications, so create a subscriber list with this key.
      'taxon_tree' => [content_item['content_id']]
    }
  end

  def content_item_type
    content_item.dig('document_type')
  end
end
