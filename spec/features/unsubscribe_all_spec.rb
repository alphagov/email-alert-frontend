RSpec.feature "Bulk unsubscribe after receiving confirmation link" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_have_multiple_subscriptions
    when_i_visit_the_manage_my_subscriptions_page
    and_i_click_on_unsubscribe_from_everything
    and_i_confirm_to_unsubscribe
    then_i_can_see_i_have_been_unsubscribed
  end

  def given_i_have_multiple_subscriptions
    @address = "test@test.com"
    @subscriber_id = SecureRandom.uuid
    stub_email_alert_api_has_subscriber_subscriptions(
      @subscriber_id,
      @address,
      nil,
      subscriptions: [subscription, subscription],
    )
  end

  def when_i_visit_the_manage_my_subscriptions_page
    token = encrypt_and_sign_token(data: {
      "address" => @address,
      "subscriber_id" => @subscriber_id,
    })
    visit process_sign_in_token_path(token: token)
  end

  def and_i_click_on_unsubscribe_from_everything
    click_on "Unsubscribe from everything"
  end

  def and_i_confirm_to_unsubscribe
    @request = stub_email_alert_api_unsubscribes_a_subscriber(@subscriber_id)
    click_on "Unsubscribe"
  end

  def then_i_can_see_i_have_been_unsubscribed
    expect(@request).to have_been_requested
    expect(page).to have_content("You have been unsubscribed from all your subscriptions")
  end

private

  def subscription
    {
      "id" => SecureRandom.uuid,
      "created_at" => Time.zone.now,
      "subscriber_list" => {
        "id" => SecureRandom.uuid,
      },
    }
  end
end
