module EmailVolume
  class TopicalEventWeeklyEmailVolume
    VOLUME = "40 to 60".freeze
    COROVIRUS_TOPICAL_EVENT_BASE_PATH = "/government/topical-events/coronavirus-covid-19-uk-government-response".freeze

    private_constant :COROVIRUS_TOPICAL_EVENT_BASE_PATH

    def initialize(content_item)
      @content_item = content_item
    end

    def estimate
      VOLUME if coronavirus_topical_event?
    end

  private

    def coronavirus_topical_event?
      @content_item["base_path"] == COROVIRUS_TOPICAL_EVENT_BASE_PATH
    end
  end
end
