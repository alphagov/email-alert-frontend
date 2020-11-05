module FrequenciesHelper
  def valid_frequencies
    t("frequencies").map { |frequency, _config| frequency.to_s }
  end

  def frequencies(options = {})
    [
      frequency_item("daily", options),
      frequency_item("weekly", options),
      :or,
      frequency_item("immediately", options),
    ]
  end

  def frequency_item(key, options)
    {
      value: key.to_sym,
      text: t("frequencies.#{key}"),
      checked: (options[:checked_frequency] == key),
    }
  end
end
