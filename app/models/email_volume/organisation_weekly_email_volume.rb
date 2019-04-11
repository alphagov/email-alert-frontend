module EmailVolume
  class OrganisationWeeklyEmailVolume
    HIGH = '40 - 60'.freeze
    MEDIUM = '0 - 20'.freeze
    LOW = '0 - 5'.freeze

    def initialize(organisation)
      @organisation = organisation
    end

    def estimate
      parent_organisation = extract_parent_from(@organisation)

      # It's a top-level organisation like HM Treasury
      return HIGH if parent_organisation.blank?

      # Is a 2nd level organisation like UK Debt Management Office
      grandparent_organisation = extract_parent_from(
        fetch_content_item(parent_organisation.fetch('base_path'))
      )
      return MEDIUM if grandparent_organisation.blank?

      # Is a 3rd level organisation
      LOW
    end

  private

    def extract_parent_from(content_item)
      Array(content_item.dig('links', 'ordered_parent_organisations')).first
    end

    def fetch_content_item(base_path)
      EmailAlertFrontend.services(:content_store).content_item(base_path)
    end
  end
end
