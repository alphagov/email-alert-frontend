Given(/^a taxon in the middle of the taxonomy$/) do
  @taxon = {
    content_id: 'taxon-uuid',
    base_path: '/education/further-education',
    title: 'Further education',
    description: 'Further education content',
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
end

When(/^i visit its signup page$/) do
  visit new_taxonomy_signup_path(paths: [@taxon[:base_path]] )
end

Then(/^i can subscribe to the taxon or one of its children$/) do
  taxon_path = @taxon[:base_path]
  child_taxon_path = @taxon.dig(:links, :child_taxons).first[:base_path]

  expect(page).to have_link(href: confirm_taxonomy_signup_path(paths: [taxon_path]))
  expect(page).to have_link(href: confirm_taxonomy_signup_path(paths: [child_taxon_path]))
end

When(/^i choose to subscribe to the taxon$/) do
  click_link(href: confirm_taxonomy_signup_path(paths: [@taxon[:base_path]]))
end

Then(/^i see a confirmation page$/) do
  expect(page).to have_content("You can set your preferences once you've signed up.")
  expect(page).to have_button('Sign up now')
end

When(/^i confirm$/) do
  @subscription_params = {
    'title' => @taxon[:title],
    'links' => { 'taxons' => [ @taxon[:content_id] ] },
  }

  @subscriber_list = {
    'subscription_url' => '/govdelivery-redirect',
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

Then(/^i am redirected to manage my subscriptions off of govuk$/) do
  expect(current_path).to eq '/govdelivery-redirect'
end

