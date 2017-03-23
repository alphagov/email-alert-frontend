class TaxonomySignup
  attr_accessor :taxon, :subscription_management_url

  def initialize(taxon)
    @taxon = taxon
  end

  def save
    return false unless taxon.present?
    self.subscription_management_url = update_subscription.dig(
      'subscriber_list', 'subscription_url'
    )
    true
  end

private

  def update_subscription
    EmailAlertFrontend.services(:email_alert_api)
      .find_or_create_subscriber_list(subscription_params)
  end

  def subscription_params
    {
      'title' => taxon['title'],
      'links' => {
        'taxons' => [taxon['content_id']]
      }
    }
  end
end

