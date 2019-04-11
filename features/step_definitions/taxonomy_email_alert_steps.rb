# rubocop:disable Metrics/BlockLength
Given(/^a taxon in the middle of the taxonomy$/) do
  @taxon = {
    content_id: 'taxon-uuid',
    base_path: '/education/further-education',
    title: 'Further education',
    description: 'Further education content',
    document_type: 'taxon',
    links: {
      parent_taxons: [
        {
          base_path: '/education',
          title: 'Education',
          description: 'Education content',
          links: {},
        }
      ],
      child_taxons: [
        {
          base_path: '/education/funding',
          title: 'Funding',
          description: 'Funding content',
          links: {
            parent_taxons: [
              {
                base_path: '/education/further-education',
                title: 'Further education',
                description: 'Further education content',
                links: {},
              }
            ]
          }
        }
      ],
    }
  }

  content_store_has_item(@taxon[:base_path], @taxon)
  content_store_has_item(
    @taxon.dig(:links, :parent_taxons).first[:base_path],
    @taxon.dig(:links, :parent_taxons).first
  )
end

When(/^i visit its signup page$/) do
  visit new_content_item_signup_path(topic: @taxon[:base_path])
end

Then(/^i can subscribe to the taxon or one of its children$/) do
  expect(page).to have_content(@taxon[:title])
  expect(page).to have_content(@taxon.dig(:links, :child_taxons).first[:title])
end

When(/^i choose to subscribe to the taxon$/) do
  choose @taxon[:title]
  click_button 'Select'
end

Then(/^i see a confirmation page$/) do
  expect(page).to have_content("You can set your preferences once you've signed up.")
  # Based on the position of this taxon in the taxonomy:
  expect(page).to have_content("This might be between 0 - 20 updates a week")
  expect(page).to have_button('Sign up now')
end

When(/^i confirm$/) do
  @subscription_params = {
    'title' => @taxon[:title],
    'links' => { 'taxon_tree' => [@taxon[:content_id]] },
  }

  @subscriber_list = {
    'subscription_url' => "/email/subscriptions/new?topic_id=#{@taxon[:title].parameterize}",
  }

  allow(@mock_email_alert_api).to receive(:find_or_create_subscriber_list)
    .with(@subscription_params)
    .and_return('subscriber_list' => @subscriber_list)

  click_button 'Sign up now'
end

Then(/^my subscription is created$/) do
  expect(@mock_email_alert_api).to have_received(:find_or_create_subscriber_list)
    .with(@subscription_params)
end

Then(/^i am redirected to manage my subscriptions$/) do
  expect(page).to have_current_path("/email/subscriptions/new?topic_id=#{@taxon[:title].parameterize}")
end
# rubocop:enable Metrics/BlockLength
