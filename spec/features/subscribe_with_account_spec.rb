RSpec.feature "Subscribe" do
  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_i_have_a_govuk_account
    given_there_is_content_i_can_subscribe_to
    when_i_visit_the_email_signup_page
    and_i_choose_a_frequency
    and_i_enter_my_email_address
    then_i_expect_to_be_told_i_have_an_account
    then_i_expect_the_login_button_to_redirect_me_to_a_login
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

  def then_i_expect_to_be_told_i_have_an_account
    expect(@request).not_to have_been_requested
    expect(page).to have_content(I18n.t!("subscriptions.use_your_govuk_account.heading"))
  end

  def then_i_expect_the_login_button_to_redirect_me_to_a_login
    # this stub allows us to go through the double-redirect if everything is working
    # but if the redirect bounce is broken it will fail, catching problems like this
    # https://github.com/alphagov/email-alert-frontend/pull/1594 at test time.
    @account_bounce_request =
      stub_request(:get, "http://account-api.dev.gov.uk/api/oauth2/sign-in?mfa=false&redirect_path=/email/subscriptions/account/confirm?frequency=weekly%26topic_id=#{@topic_id}")
        .to_return(status: 200, body: { auth_uri: "/" }.to_json, headers: {})

    click_on I18n.t!("subscriptions.use_your_govuk_account.continue")
    expect(@account_bounce_request).to have_been_requested
  end
end
