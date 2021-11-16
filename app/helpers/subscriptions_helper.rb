module SubscriptionsHelper
  def get_updated_at_from_subscription(subscription)
    base_path = subscription["subscriber_list"]["url"]
    content_item = GdsApi.content_store.content_item(base_path)

    content_item["public_updated_at"]
  end

  def get_heading_content(subscription)
    if subscription.dig("subscriber_list", "content_id").present?
      link_to subscription["subscriber_list"]["title"], subscription["subscriber_list"]["url"], class: "govuk-link"
    else
      subscription["subscriber_list"]["title"]
    end
  end
end
