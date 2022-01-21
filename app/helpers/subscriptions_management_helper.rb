module SubscriptionsManagementHelper
  def get_subscription_title(subscription)
    subscription["subscriber_list"]["title"]
  end
end
