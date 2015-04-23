require 'ostruct'

module EmailAlertSignupHelper
  include GovukContentSchemaExamples

  def content_store_has_employment_email_alert_signup(base_path:, tags:)
    content_store_has_item(base_path, govuk_content_schema_example("email_alert_signup").merge(tags).to_json)
  end

  def expect_registration_to(title:, tags:, base_path:)
    subscription_params = {
      "title" => title,
      "tags" => tags
    }

    allow(EmailAlertFrontend.services(:email_alert_api)).
      to receive(:find_or_create_subscriber_list).
      with(subscription_params).
      and_return(OpenStruct.new("subscriber_list" => OpenStruct.new("subscription_url" => base_path)))

    expect(EmailAlertFrontend.services(:email_alert_api)).
      to have_received(:find_or_create_subscriber_list).
      with(subscription_params)
  end

  def subscribe_to_email_alerts
    click_on "Create subscription"
  end
end

World(EmailAlertSignupHelper)
