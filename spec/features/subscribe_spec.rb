RSpec.feature "Subscribe" do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_there_is_content_i_can_subscribe_to
    when_i_visit_the_email_signup_page
    and_i_choose_a_frequency
    and_i_enter_my_email_address
    then_i_should_be_subscribed
  end

  def given_there_is_content_i_can_subscribe_to
    @topic_id = SecureRandom.uuid
    @subscriber_list_id = SecureRandom.uuid

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @topic_id,
      returned_attributes: {
        id: @subscriber_list_id,
        title: "Test Subscriber List",
      },
    )
  end

  def when_i_visit_the_email_signup_page
    visit new_subscription_path(topic_id: @topic_id)
  end

  def and_i_choose_a_frequency
    expect(page).to have_content("How often do you want to get updates?")
    @frequency = "weekly"
    choose "frequency", option: @frequency, visible: false
    click_on "Next"
  end

  def and_i_enter_my_email_address
    expect(back_link_href).to include(new_subscription_path(topic_id: @topic_id))
    expect(page).to have_content("What’s your email address?")

    address = "test@test.com"
    fill_in :address, with: address

    @request = email_alert_api_creates_a_subscription(
      @subscriber_list_id,
      address,
      @frequency,
      "returned_subscriber_id",
    )

    click_on "Subscribe"
  end

  def then_i_should_be_subscribed
    expect(@request).to have_been_requested
    expect(page).to have_content("You’ve subscribed successfully")
    expect(page).to have_content("Test Subscriber List")
    expect(back_link_href).to include(new_subscription_path(topic_id: @topic_id))
  end

  def back_link_href
    page.find("a", text: "Back")[:href]
  end
end
