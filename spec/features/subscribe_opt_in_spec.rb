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
    @frequency = "immediately"
    @address = "test@example.com"
  end

  def when_i_click_on_the_confirmation_link
    @title = "Test Subscriber List"

    token = jwt_token(data: {
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
      @frequency,
      nil,
    )

    visit confirm_subscription_path(
      token: token,
      topic_id: @topic_id,
      frequency: @frequency,
    )
  end

  def then_i_see_i_am_subscribed
    expect(@request).to have_been_requested
    expect(page).to have_content("You’ve subscribed successfully")
    description = I18n.t!("frequencies.#{@frequency}.subscribed_to_topic", title: @title)
    expect(page).to have_content(description)
  end
end
