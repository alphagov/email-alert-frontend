RSpec.feature "Subscribe with default frequency" do
  include GdsApi::TestHelpers::EmailAlertApi

  background do
    given_there_is_content_i_can_subscribe_to
  end

  scenario do
    when_i_signup_with_a_default_frequency
    then_i_see_the_frequency_is_preset
  end

  def given_there_is_content_i_can_subscribe_to
    @topic_id = SecureRandom.uuid
    subscriber_list_id = SecureRandom.uuid

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @topic_id,
      returned_attributes: {
        id: subscriber_list_id,
        title: "Test Subscriber List",
      },
    )
  end

  def when_i_signup_with_a_default_frequency
    visit new_subscription_path(topic_id: @topic_id, default_frequency: "daily")
  end

  def then_i_see_the_frequency_is_preset
    expect(find_field(name: "frequency", checked: true).value).to eq "daily"
  end
end
