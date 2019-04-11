module EmailVolume
  class WeeklyEmailVolume
    def initialize(content_item)
      @content_item = content_item
    end

    def estimate
      volume_estimator.estimate
    end

  private

    class ContentItemNotEstimatableError < StandardError; end

    def volume_estimator
      case content_item_type
      when 'taxon'
        TaxonWeeklyEmailVolume.new(@content_item)
      else
        error_message = "Volume estimate not possible for content items of type #{content_item_type}!"
        raise ContentItemNotEstimatableError, error_message
      end
    end

    def content_item_type
      @content_item.dig('document_type')
    end
  end
end
