module EmailVolume
  class TaxonWeeklyEmailVolume
    EXTREME = "200 to 800".freeze
    HIGH = "40 to 60".freeze
    MEDIUM = "0 to 20".freeze
    LOW = "0 to 5".freeze

    def initialize(taxon)
      @taxon = taxon
    end

    def estimate
      parent_taxon = extract_parent_from(@taxon)

      # Is for covid-19
      return EXTREME if @taxon.dig("base_path") == "/coronavirus-taxon"

      # Is at the top of the taxonomy
      return HIGH if parent_taxon.blank?

      # Is a 2nd level taxon
      grandparent_taxon = extract_parent_from(
        fetch_content_item(parent_taxon.fetch("base_path")),
      )
      return MEDIUM if grandparent_taxon.blank?

      # Is a 3rd level taxon or below
      LOW
    end

  private

    def extract_parent_from(content_item)
      Array(content_item.dig("links", "parent_taxons")).first
    end

    def fetch_content_item(base_path)
      EmailAlertFrontend.services(:content_store).content_item(base_path)
    end
  end
end
