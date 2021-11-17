module SubscriptionsHelper
  def get_updated_at_from_subscription(subscription)
    base_path = subscription["subscriber_list"]["url"]
    content_item = GdsApi.content_store.content_item(base_path)

    content_item["public_updated_at"]
  end
end
