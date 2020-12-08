RSpec.feature "Unsubscribe" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario "when using a one-click link" do
    given_i_have_a_subscription
    when_i_visit_the_unsubscribe_page
    and_i_confirm_to_unsubscribe
    then_i_see_that_i_am_unsubscribed
  end

  scenario "when managing subscriptions" do
    given_i_have_a_subscription
    and_i_have_a_secret_sign_in_token
    when_i_visit_the_management_page
    and_i_click_on_unsubscribe
    and_i_confirm_to_unsubscribe
    then_i_see_the_management_page
  end

  def given_i_have_a_subscription
    @subscription_id = SecureRandom.uuid
    @title = "A thing to subscribe to"
    @subscriber_id = SecureRandom.uuid

    stub_email_alert_api_has_subscription(
      @subscription_id,
      "immediately",
      title: @title,
      subscriber_id: @subscriber_id,
    )
  end

  def when_i_visit_the_unsubscribe_page
    token = encrypt_and_sign_token(data: { "subscriber_id" => @subscriber_id })
    visit confirm_unsubscribe_path(@subscription_id, token: token)
  end

  def and_i_have_a_secret_sign_in_token
    @address = "test@test.com"

    @token = encrypt_and_sign_token(data: {
      "address" => @address,
      "subscriber_id" => @subscriber_id,
    })
  end

  def when_i_visit_the_management_page
    stub_email_alert_api_has_subscriber_subscriptions(
      @subscriber_id,
      @address,
      nil,
      subscriptions: [
        {
          "id" => @subscription_id,
          "created_at" => Time.zone.now,
          "subscriber_list" => {},
        },
      ],
    )

    visit process_sign_in_token_path(token: @token)
  end

  def and_i_click_on_unsubscribe
    click_on "Unsubscribe"
  end

  def and_i_confirm_to_unsubscribe
    @unsubscribe_request = stub_email_alert_api_unsubscribes_a_subscription(
      @subscription_id,
    )
    click_on "Unsubscribe"
  end

  def then_i_see_that_i_am_unsubscribed
    expect(@unsubscribe_request).to have_been_requested
    expect(page).to have_content(
      I18n.t!("unsubscriptions.confirmation.with_title", title: @title),
    )
  end

  def then_i_see_the_management_page
    expect(current_path).to eq list_subscriptions_path
    expect(page).to have_content(
      I18n.t!("subscriptions_management.index.unsubscribe.message", title: @title),
    )
  end
end
