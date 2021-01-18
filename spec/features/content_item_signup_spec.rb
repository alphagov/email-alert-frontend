RSpec.feature "Content item signup" do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  scenario "generic content item" do
    given_there_is_an_organisation
    when_i_visit_the_signup_page
    and_i_click_to_signup_to_alerts
    then_i_can_subscribe_to_alerts
  end

  scenario "taxon with children" do
    given_there_is_a_topic
    when_i_visit_the_signup_page
    and_i_refine_my_selection
    and_i_click_to_signup_to_alerts
    then_i_can_subscribe_to_alerts
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

  def when_i_visit_the_signup_page
    visit new_content_item_signup_path(link: @content_item[:base_path])
    expect(page).to have_content(@content_item[:title])
  end

  def and_i_refine_my_selection
    expect(page).to_not have_checked_field
    expect(page).to have_content(@content_item.dig(:links, :child_taxons).first[:title])

    choose @content_item[:title]
    click_button "Continue"
  end

  def and_i_click_to_signup_to_alerts
    stub_email_alert_api_has_subscriber_list(
      "links" => { @links_type => [@content_item[:content_id]] },
      "slug" => "my-list",
    )

    stub_email_alert_api_has_subscriber_list_by_slug(slug: "my-list", returned_attributes: {})
    click_on "Continue"
  end

  def then_i_can_subscribe_to_alerts
    expected_path = new_subscription_path(topic_id: "my-list")
    expect(page).to have_current_path(expected_path)
  end
end
