require 'rails_helper'

RSpec.describe "Subscribing to the taxonomy", type: :feature do
  include GdsApi::TestHelpers::ContentStore

  it "can handle any valid taxon" do
    10.times do
      document = GovukSchemas::RandomExample.for_schema(frontend_schema: "taxon")
      content_store_has_item(document['base_path'], document)

      visit "/email-signup?topic=#{document['base_path']}"

      expect(page).to have_content document["title"]
    end
  end
end
