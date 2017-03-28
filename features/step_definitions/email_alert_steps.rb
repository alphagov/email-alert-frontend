Given(/^a content item exists for an email alert signup page$/) do
  content_item = govuk_content_schema_example("policy_email_alert_signup")
  @base_path = content_item["base_path"]
  @alert_type = content_item["details"]["email_alert_type"]
  @parent_id = content_item["links"]["parent"].first["content_id"]
  @tags = content_item["details"]["subscriber_list"]["tags"]
  content_store_has_item(@base_path, content_item.to_json)
end

When(/^I access the email signup page$/) do
  visit @base_path
end

Then(/^I see the email signup page$/) do
  within(shared_component_selector("title")) do
    expect(page).to have_content("Employment")
  end
end

When(/^I sign up to the email alerts$/) do
  @subscription_params = {
    'title' => 'Employment policy',
    'tags' => @tags,
  }

  @subscriber_list = {
    'subscription_url' => '/govdelivery-redirect',
  }

  allow(@mock_email_alert_api).to receive(:find_or_create_subscriber_list)
    .with(@subscription_params)
    .and_return('subscriber_list' => @subscriber_list)

  click_on "Create subscription"
end

Then(/^my subscription should be registered$/) do
  expect(@mock_email_alert_api).to have_received(:find_or_create_subscriber_list)
    .with(@subscription_params)
  expect(current_path).to eq '/govdelivery-redirect'
end

Given(/^a government email alert page exists$/) do
  step("a content item exists for an email alert signup page")
end

Then(/^I can see the government header$/) do
  visit email_alert_signup_path('government/policies/employment/email-signup')
  expect(page).to have_css(shared_component_selector('government_navigation'))
end
