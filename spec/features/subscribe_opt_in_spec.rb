RSpec.feature "Subscribe opt-in" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_am_subscribing_to_a_list
    when_i_click_on_the_confirmation_link
    then_i_see_i_am_subscribed
  end

  def given_i_am_subscribing_to_a_list
    @topic_id = SecureRandom.uuid
    @subscriber_list_id = SecureRandom.uuid
    @address = "test@example.com"
  end

  def when_i_click_on_the_confirmation_link
    @title = "Test Subscriber List"

    token = encrypt_and_sign_token(data: {
      "address" => @address,
      "topic_id" => @topic_id,
    })

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @topic_id,
      returned_attributes: {
        id: @subscriber_list_id,
        title: @title,
      },
    )

    @request = stub_email_alert_api_creates_a_subscription(
      @subscriber_list_id,
      @address,
      "immediately",
      nil,
    )

    visit confirm_subscription_path(
      token: token,
      topic_id: @topic_id,
      frequency: "immediately",
    )
  end

  def then_i_see_i_am_subscribed
    expect(@request).to have_been_requested
    expect(page).to have_content("You’ve subscribed successfully")
    expect(page).to have_content("You’ll get an email each time there’s an update to: Test Subscriber List")
  end
end
