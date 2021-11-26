module FrequenciesHelper
  def valid_frequencies
    t("frequencies.topic").map { |frequency, _config| frequency.to_s }
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
    subscription_type = options[:is_single_page] ? "page" : "topic"
    {
      value: key.to_sym,
      text: t("frequencies.#{subscription_type}.#{key}"),
      checked: (options[:checked_frequency] == key),
    }
  end
end
