RSpec.describe "Subscribing to the taxonomy" do
  include GdsApi::TestHelpers::ContentStore

  it "can handle any valid taxon" do
    10.times do
      document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon")
      content_store_has_item(document["base_path"], document)

      visit "/email-signup?topic=#{document['base_path']}"

      expect(page).to have_content document["title"]
    end
  end

  it "shows navigation links for live taxons" do
    document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon") do |doc|
      doc.merge("phase" => "live")
    end

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to have_link "Back", href: document["base_path"]
  end

  it "doesn't show links for non-live taxons" do
    document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon") do |doc|
      doc.merge("phase" => "alpha")
    end

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to_not have_link "Back", href: document["base_path"]
  end
end
