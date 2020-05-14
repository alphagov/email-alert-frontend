RSpec.feature "Change email frequency after receiving confirmation link" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_have_a_subscription
    when_i_visit_the_manage_my_subscriptions_page
    then_i_can_see_i_am_subscribed_to_daily_updates
    when_i_click_to_change_how_often_i_get_updates
    and_i_select_once_a_week
    then_i_can_see_that_i_am_subscribed_to_weekly_updates
  end

  def given_i_have_a_subscription
    @address = "test@test.com"
    @subscriber_id = SecureRandom.uuid
    @subscription_id = SecureRandom.uuid
    @subscription_title = "Something to subscribe to"

    stub_email_alert_api_has_subscriber_subscriptions(
      @subscriber_id, @address, nil, subscriptions: [subscription]
    ).then
     .to_return(status: 200,
                body: subscriber_subscriptions_response_with_weekly_frequency)
  end

  def when_i_visit_the_manage_my_subscriptions_page
    token = encrypt_and_sign_token(data: {
      "address" => @address,
      "subscriber_id" => @subscriber_id,
    })

    visit process_sign_in_token_path(token: token)
  end

  def then_i_can_see_i_am_subscribed_to_daily_updates
    expect(page).to have_content(
      I18n.t!("subscriptions_management.index.subscription.daily"),
    )
  end

  def when_i_click_to_change_how_often_i_get_updates
    click_on "Change how often you get updates"
  end

  def and_i_select_once_a_week
    @request = stub_email_alert_api_has_updated_subscription(@subscription_id, "weekly")

    choose "Once a week"
    click_on "Save"
  end

  def then_i_can_see_that_i_am_subscribed_to_weekly_updates
    expect(@request).to have_been_requested
    expect(page).to have_content(
      I18n.t!(
        "subscriptions_management.change_frequency.success",
        subscription_title: @subscription_title,
        frequency: "weekly",
      ),
    )
  end

private

  def subscription
    {
      "id" => @subscription_id,
      "created_at" => Time.zone.now,
      "frequency" => "daily",
      "subscriber_list" => {
        "title" => @subscription_title,
      },
    }
  end

  def subscriber_subscriptions_response_with_weekly_frequency
    {
      "subscriber" => {
        "id" => @subscriber_id,
        "address" => @address,
      },
      "subscriptions" => [subscription.merge("frequency" => "weekly")],
    }.to_json
  end
end
