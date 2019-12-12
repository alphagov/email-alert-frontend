RSpec.feature "Unsubscribe after receiving confirmation link" do
  include GdsApi::TestHelpers::EmailAlertApi

  scenario do
    given_i_have_a_subscription
    when_i_visit_the_unsubscribe_page
    and_i_click_on_unsubscribe
    then_i_see_that_i_am_unsubscribed
  end

  def given_i_have_a_subscription
    @subscriber_list_id = SecureRandom.uuid
    @title = "A thing to subscribe to"
    stub_email_alert_api_has_subscription(
      @subscriber_list_id,
      "immediately",
      title: @title,
    )
  end

  def when_i_visit_the_unsubscribe_page
    visit confirm_unsubscribe_path(@subscriber_list_id)
  end

  def and_i_click_on_unsubscribe
    @unsubscribe_request = stub_email_alert_api_unsubscribes_a_subscription(
      @subscriber_list_id,
    )
    click_on "Unsubscribe"
  end

  def then_i_see_that_i_am_unsubscribed
    expect(@unsubscribe_request).to have_been_requested
    expect(page).to have_content(
      "You won’t get any more updates about #{@title}.",
    )
  end
end
