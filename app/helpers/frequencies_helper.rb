module FrequenciesHelper
  def valid_frequencies
    t("frequencies").map { |frequency, _config| frequency.to_s }
  end

  def frequencies(options = {})
    t("frequencies").map do |frequency, desc|
      {
        value: frequency,
        text: desc,
        checked: (options[:checked_frequency] == frequency.to_s),
      }
    end
  end
end
