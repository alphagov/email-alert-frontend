RSpec.feature "Topic signup back" do
  include GovukContentSchemaExamples

  scenario "live taxon" do
    document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon") do |doc|
      doc.merge("phase" => "live")
    end

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to have_link "Back", href: document["base_path"]
  end

  scenario "alpha taxon" do
    document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon") do |doc|
      doc.merge("phase" => "alpha")
    end

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to_not have_link "Back", href: document["base_path"]
  end
end
