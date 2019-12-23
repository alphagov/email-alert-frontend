RSpec.feature "Subscribe back" do
  include GdsApi::TestHelpers::EmailAlertApi

  background do
    given_there_is_content_i_can_subscribe_to
  end

  scenario "from GOV.UK" do
    when_i_start_signup_via_govuk
    then_i_see_a_link_back_to_govuk
  end

  scenario "with referrer" do
    when_i_start_signup_externally
    then_i_can_only_go_back_to_govuk
  end

  scenario "confirm email" do
    when_i_start_signup_via_govuk
    and_i_select_frequency_and_submit
    and_i_fill_in_my_email
    then_i_can_see_a_back_url_with_correct_parameters
  end

  def given_there_is_content_i_can_subscribe_to
    @topic_id = SecureRandom.uuid

    stub_email_alert_api_has_subscriber_list_by_slug(
      slug: @topic_id,
      returned_attributes: {
        id: SecureRandom.uuid,
        title: "Test Subscriber List",
      },
    )
  end

  def when_i_confirm_my_email
    visit "/email/subscriptions/verify?topic_id=#{@topic_id}?frequency=1&address=user@domain.uk"
  end

  def when_i_start_signup_via_govuk
    visit "/email/subscriptions/new?topic_id=#{@topic_id}"
  end

  def and_i_select_frequency_and_submit
    stub_email_alert_api_sends_subscription_verification_email("person@somewhere.uk", "daily", @topic_id)
    choose(option: "daily")
    click_on "Continue"
  end

  def and_i_fill_in_my_email
    fill_in "address", with: "person@somewhere.uk"
    click_on "Continue"
  end

  def when_i_start_signup_externally
    page.driver.header("Referer", "http://example.com/some/page?query=string")
    when_i_start_signup_via_govuk
  end

  def then_i_see_a_link_back_to_govuk
    expect(back_link_href).to match(%r{gov.uk$})
  end

  def then_i_can_only_go_back_to_govuk
    expect(back_link_href).to match(%r{gov.uk/some/page\?query=string$})
  end

  def then_i_can_see_a_back_url_with_correct_parameters
    expect(back_link_href).to match(%r{gov.uk})
    params = Rack::Utils.parse_query(URI.parse(back_link_href).query).symbolize_keys
    expect(params).to include(frequency: "daily", topic_id: @topic_id, address: "person@somewhere.uk")
  end

  def back_link_href
    page.find("a", text: "Back")[:href]
  end
end
