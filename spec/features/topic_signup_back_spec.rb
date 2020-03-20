RSpec.feature "Topic signup back" do
  include GovukContentSchemaExamples

  scenario "live taxon with children" do
    document = GovukSchemas::Example.find("taxon", example_name: "taxon_with_child_taxons")
    document.merge!("phase" => "live")

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to have_link "Back", href: document["base_path"]
  end

  scenario "alpha taxon with children" do
    document = GovukSchemas::Example.find("taxon", example_name: "taxon_with_child_taxons")
    document.merge!("phase" => "alpha")

    content_store_has_item(document["base_path"], document)
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to_not have_link "Back", href: document["base_path"]
  end

  scenario "live taxon without children" do
    document = GovukSchemas::Example.find("taxon", example_name: "taxon")
    document.merge!("phase" => "live")

    content_store_has_item(document["base_path"], document)
    content_store_has_item(
      document["links"]["parent_taxons"].first["base_path"],
      document["links"]["parent_taxons"].first,
    )
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to have_link "Back", href: "javascript:history.back()"
  end

  scenario "alpha taxon without children" do
    document = GovukSchemas::Example.find("taxon", example_name: "taxon")
    document.merge!("phase" => "alpha")

    content_store_has_item(document["base_path"], document)
    content_store_has_item(
      document["links"]["parent_taxons"].first["base_path"],
      document["links"]["parent_taxons"].first,
    )
    visit "/email-signup?topic=#{document['base_path']}"

    expect(page).to_not have_link "Back", href: document["base_path"]
  end
end
