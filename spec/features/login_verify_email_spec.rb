RSpec.feature "Login verify email" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_am_managing_my_subscriptions
    when_i_click_on_the_verification_link
    then_i_can_manage_my_subscriptions
  end

  def given_i_am_managing_my_subscriptions
    @subscriber_id = 1
  end

  def when_i_click_on_the_verification_link
    token = encrypt_and_sign_token(data: {
      "subscriber_id" => @subscriber_id,
    })

    stub_email_alert_api_has_subscriber_subscriptions(
      @subscriber_id,
      "foo@bar.com",
      nil,
      subscriptions: [],
    )

    visit process_sign_in_token_path(token: token)
  end

  def then_i_can_manage_my_subscriptions
    expect(page).to have_content(I18n.t!("subscriptions_management.heading"))
  end
end
