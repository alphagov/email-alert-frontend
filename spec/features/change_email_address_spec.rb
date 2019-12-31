RSpec.feature "Change email address after receiving confirmation link" do
  include GdsApi::TestHelpers::EmailAlertApi
  include TokenHelper

  scenario do
    given_i_am_a_subscriber
    when_i_visit_the_manage_my_subscriptions_page
    and_i_click_to_change_my_email_address
    and_i_enter_a_new_email_address
    then_i_can_see_that_my_email_address_has_been_changed
  end

  def given_i_am_a_subscriber
    @current_email_address = "test@test.com"
    @subscriber_id = SecureRandom.uuid
  end

  def when_i_visit_the_manage_my_subscriptions_page
    stub_email_alert_api_has_subscriber_subscriptions(
      @subscriber_id,
      @current_email_address,
      nil,
      subscriptions: [],
    )

    token = encrypt_and_sign_token(data: {
      "address" => @current_email_address,
      "subscriber_id" => @subscriber_id,
    })

    visit process_sign_in_token_path(token: token)
  end

  def and_i_click_to_change_my_email_address
    click_on "Change email address"
  end

  def and_i_enter_a_new_email_address
    @new_email_address = "another@email.com"
    @request = stub_email_alert_api_has_updated_subscriber(@subscriber_id, @new_email_address)

    fill_in "What’s your new email address?", with: @new_email_address
    click_on "Save"
  end

  def then_i_can_see_that_my_email_address_has_been_changed
    expect(@request).to have_been_requested
    expect(page).to have_content(
      "Your email address has been changed to #{@new_email_address}",
    )
  end
end
