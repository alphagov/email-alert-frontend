module FrequenciesHelper
  def valid_frequencies
    I18n.t('frequencies').map { |frequency, _config| frequency.to_s }
  end

  def frequencies(options)
    I18n.t('frequencies').map { |frequency, config|
      {
        value: frequency,
        text: config[:short_desc],
        checked: (options[:checked_frequency] == frequency.to_s),
      }
    }
  end
end
