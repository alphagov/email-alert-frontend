RSpec.feature "Login check email" do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    when_i_visit_the_manage_page
    and_i_enter_my_email_address
    then_i_expect_to_get_an_email
  end

  def when_i_visit_the_manage_page
    visit sign_in_path
  end

  def and_i_enter_my_email_address
    email_address = "test@test.com"
    subscriber_id = SecureRandom.uuid

    @request = stub_email_alert_api_sends_subscriber_verification_email(
      subscriber_id, email_address
    )

    fill_in :address, with: email_address
    click_on "Continue"
  end

  def then_i_expect_to_get_an_email
    expect(@request).to have_been_requested
    expect(page).to have_content(
      I18n.t!("subscriber_authentication.request_sign_in_token.heading"),
    )
  end
end
