module EmailVolume
  class WeeklyEmailVolume
    def initialize(content_item)
      @content_item = content_item
    end

    def estimate
      volume_estimator&.estimate
    end

  private

    def volume_estimator
      case content_item_type
      when "taxon"
        TaxonWeeklyEmailVolume.new(@content_item)
      when "organisation"
        OrganisationWeeklyEmailVolume.new(@content_item)
      when "topical_event"
        TopicalEventWeeklyEmailVolume.new(@content_item)
      end
    end

    def content_item_type
      @content_item.dig("document_type")
    end
  end
end
