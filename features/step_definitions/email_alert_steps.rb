Given(/^a content item exists for an email alert signup page$/) do
  @base_path = "/government/policies/employment/email-signup"
  @tags = {
    "policy"=> ["employment"]
  }
  content_store_has_employment_email_alert_signup(base_path: @base_path, tags: @tags)
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
  subscribe_to_email_alerts
end

Then(/^my subscription should be registered$/) do
  expect_registration_to(title: "Employment", tags: @tags, base_path: @base_path)
end
