RSpec.feature "Subscribe" do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_i_have_a_govuk_account
    given_there_is_content_i_can_subscribe_to
    when_i_visit_the_email_signup_page
    and_i_choose_a_frequency
    and_i_enter_my_email_address
    then_i_expect_to_sign_in
  end

  def given_i_have_a_govuk_account
    stub_account_api_match_user_by_email_does_not_match(email: "test@test.com")
  end

  def given_there_is_content_i_can_subscribe_to
    @topic_id = SecureRandom.uuid
    @subscriber_list_id = SecureRandom.uuid

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @topic_id,
      returned_attributes: {
        id: @subscriber_list_id,
        title: "Test Subscriber List",
      },
    )
  end

  def when_i_visit_the_email_signup_page
    visit new_subscription_path(topic_id: @topic_id)
  end

  def and_i_choose_a_frequency
    expect(page).to have_content(I18n.t!("subscriptions.new_frequency.title"))
    @frequency = "weekly"
    choose "frequency", option: @frequency, visible: false
    click_on "Continue"
  end

  def and_i_enter_my_email_address
    expect(page).to have_content(I18n.t!("subscriptions.new_address.title"))

    address = "test@test.com"
    fill_in :address, with: address

    @request = stub_email_alert_api_sends_subscription_verification_email(
      address,
      @frequency,
      @topic_id,
    )

    click_on "Continue"
  end

  def then_i_expect_to_sign_in
    expect(@request).not_to have_been_requested
    expect(page).to have_content(I18n.t!("subscriptions.use_your_govuk_account.heading"))
  end
end
