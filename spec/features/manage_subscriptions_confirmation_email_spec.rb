RSpec.feature "Receive confirmation email when managing subscriptions" do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_i_have_an_email_address
    when_i_visit_the_manage_my_subscriptions_page
    and_i_enter_my_email_address
    then_i_can_see_a_confirmation_email_has_been_sent_to_me
  end

  def given_i_have_an_email_address
    @email_address = "test@test.com"
  end

  def when_i_visit_the_manage_my_subscriptions_page
    visit sign_in_path
  end

  def and_i_enter_my_email_address
    subscriber_id = SecureRandom.uuid
    @request = stub_email_alert_api_sends_subscriber_verification_email(
      subscriber_id, @email_address
    )

    fill_in I18n.t!("subscriber_authentication.sign_in.email_input.label"),
            with: @email_address
    click_on "Continue"
  end

  def then_i_can_see_a_confirmation_email_has_been_sent_to_me
    expect(@request).to have_been_requested
    expect(page).to have_content(
      I18n.t!(
        "subscriber_authentication.request_sign_in_token.confirmation",
        address: @email_address,
      ),
    )
  end
end
