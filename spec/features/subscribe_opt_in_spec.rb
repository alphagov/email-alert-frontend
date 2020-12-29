RSpec.feature "Subscribe opt-in" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_am_subscribing_to_a_list
    when_i_click_on_the_confirmation_link
    then_i_see_i_am_subscribed
    and_i_can_manage_my_subscriptions
  end

  def given_i_am_subscribing_to_a_list
    @topic_id = SecureRandom.uuid
    @subscriber_list_id = SecureRandom.uuid
    @address = "test@example.com"
  end

  def when_i_click_on_the_confirmation_link
    @title = "Test Subscriber List"
    subscriber_id = 1

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
      subscriber_list_id: @subscriber_list_id,
      address: @address,
      frequency: "immediately",
      subscriber_id: subscriber_id,
    )

    stub_email_alert_api_has_subscriber_subscriptions(
      subscriber_id,
      @address,
      nil,
      subscriptions: [],
    )

    visit confirm_subscription_path(
      token: token,
      topic_id: @topic_id,
      frequency: "immediately",
    )
  end

  def then_i_see_i_am_subscribed
    expect(@request).to have_been_requested

    description = I18n.t!(
      "subscription_authentication.authenticate.description.immediately",
      title: "Test Subscriber List",
    )

    expect(page).to have_content(I18n.t!("subscription_authentication.authenticate.message"))
    expect(page).to have_content(description)
  end

  def and_i_can_manage_my_subscriptions
    expect(page).to have_content(I18n.t!("subscriptions_management.heading"))
  end
end
