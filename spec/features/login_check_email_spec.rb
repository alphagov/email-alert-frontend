RSpec.feature "Login check email" do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_i_do_not_have_a_govuk_account
    when_i_visit_the_manage_page
    and_i_enter_my_email_address
    then_i_expect_to_get_an_email
  end

  def given_i_do_not_have_a_govuk_account
    stub_account_api_match_user_by_email_does_not_exist(email: "test@test.com")
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
      I18n.t!("subscriber_authentication.check_email.heading"),
    )
  end
end
