RSpec.feature "Content item signup" do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  scenario "generic content item" do
    given_there_is_an_organisation
    when_i_visit_the_signup_page
    and_i_click_to_signup_to_alerts
    then_i_can_subscribe_to_alerts
  end

  scenario "a single page subscription button with skip account enabled" do
    given_there_is_a_piece_of_content_with_a_single_page_notification_button_with_skip_account_enabled
    when_i_visit_the_signup_page_the_single_page_subscription_param_is_set
    and_i_click_to_signup_to_alerts
    then_i_can_subscribe_to_alerts
  end

  scenario "taxon with children" do
    given_there_is_a_topic
    when_i_visit_the_signup_page
    and_i_refine_my_selection
    and_i_click_to_signup_to_taxon_alerts
    then_i_can_subscribe_to_taxon_alerts
  end

  def given_there_is_a_topic
    @links_type = "taxon_tree"
    @content_item = {
      content_id: SecureRandom.uuid,
      base_path: "/education/further-education",
      title: "Further education",
      document_type: "taxon",
      links: {
        child_taxons: [{ title: "Funding" }],
      },
    }

    stub_content_store_has_item(@content_item[:base_path], @content_item)
  end

  def given_there_is_an_organisation
    @links_type = "organisations"
    @content_item = {
      content_id: SecureRandom.uuid,
      title: "Organisation",
      base_path: "/my-organisation",
      document_type: "organisation",
    }

    stub_content_store_has_item(@content_item[:base_path], @content_item)
  end

  def given_there_is_a_piece_of_content_with_a_single_page_notification_button_with_skip_account_enabled
    @single_page_notification_with_skip_account = "true"
    @content_item = {
      content_id: SecureRandom.uuid,
      title: "Piece of content",
      base_path: "/my-content",
      document_type: "anything-goes",
      description: "Some information",
    }
    stub_content_store_has_item(@content_item[:base_path], @content_item)
  end

  def when_i_visit_the_signup_page
    visit new_content_item_signup_path(link: @content_item[:base_path])
    expect(page).to have_content(@content_item[:title])
  end

  def when_i_visit_the_signup_page_the_single_page_subscription_param_is_set
    visit new_content_item_signup_path(link: @content_item[:base_path], single_page_subscription: "true")
    expect(page).to have_content(@content_item[:title])
  end

  def and_i_refine_my_selection
    expect(page).to_not have_checked_field
    expect(page).to have_content(@content_item.dig(:links, :child_taxons).first[:title])

    choose @content_item[:title]
    click_button "Continue"
  end

  def and_i_click_to_signup_to_alerts
    generic_links_based_params = {
      "title" => @content_item[:title],
      "links" => { "organisations" => [@content_item[:content_id]] },
      "url" => @content_item[:base_path],
    }

    content_id_based_params = {
      "title" => @content_item[:title],
      "content_id" => @content_item[:content_id],
      "description" => @content_item[:description],
      "url" => @content_item[:base_path],
    }

    params =
      @single_page_notification_with_skip_account.present? ? content_id_based_params : generic_links_based_params

    assert_email_alert_api_find_and_create(params)
  end

  def and_i_click_to_signup_to_taxon_alerts
    stub_email_alert_api_creates_subscriber_list(
      "links" => { @links_type => [@content_item[:content_id]] },
      "slug" => "my-list",
    )
    stub_email_alert_api_has_subscriber_list_by_slug(slug: "my-list", returned_attributes: {})
    click_on "Continue"
  end

  def then_i_can_subscribe_to_taxon_alerts
    expected_path = new_subscription_path(topic_id: "my-list")
    expect(page).to have_current_path(expected_path)
  end

  def then_i_can_subscribe_to_alerts
    slug = @content_item[:base_path].parameterize
    expected_path = new_subscription_path(topic_id: slug)
    expect(page).to have_current_path(expected_path)
  end

  def assert_email_alert_api_find_and_create(params)
    endpoint = GdsApi::TestHelpers::EmailAlertApi::EMAIL_ALERT_API_ENDPOINT
    find_or_create_link = "#{endpoint}/subscriber-lists"
    slug = params["url"].parameterize
    email_alert_api_response = { "subscriber_list" => { "slug" => slug } }

    create_stub = stub_request(:post, find_or_create_link)
                  .with(body: hash_including(params))
                  .to_return(status: 200, body: email_alert_api_response.to_json)

    stub_email_alert_api_has_subscriber_list_by_slug(slug:, returned_attributes: {})

    click_on "Continue"

    expect(create_stub).to have_been_requested
  end
end
