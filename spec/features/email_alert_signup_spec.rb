RSpec.feature "Email alert signup" do
  include GovukContentSchemaExamples
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_there_is_a_signup_page
    when_i_visit_the_signup_page
    and_i_click_to_signup_to_alerts
    then_i_can_subscribe_to_alerts
  end

  def given_there_is_a_signup_page
    @content_item = govuk_content_schema_example("travel_advice_country_email_alert_signup")
    @base_path = @content_item["base_path"]
    @title = @content_item["title"]
    stub_content_store_has_item(@base_path, @content_item.to_json)
  end

  def when_i_visit_the_signup_page
    visit @base_path
    expect(page).to have_content(@title)
  end

  def and_i_click_to_signup_to_alerts
    @subscriber_list_id = SecureRandom.uuid

    stub_email_alert_api_creates_subscriber_list(
      @content_item["details"]["subscriber_list"].merge(
        "id" => @subscriber_list_id,
        "slug" => @subscriber_list_id,
      ),
    )

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @subscriber_list_id,
      returned_attributes: {
        "title" => @title,
      },
    )

    click_on "Continue"
  end

  def then_i_can_subscribe_to_alerts
    subscriber_list_url = new_subscription_path(topic_id: @subscriber_list_id)
    expect(page).to have_current_path(subscriber_list_url)
  end
end
