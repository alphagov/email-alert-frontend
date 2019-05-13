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

  def frequency_summary(options)
    frequency_conf = I18n.t('frequencies').select { |frequency, _config| frequency.to_s == options[:frequency] }
    frequency_conf = frequency_conf[options[:frequency].to_sym]
    message = frequency_conf[options[:message].to_sym]
    message.sub!('@title', options[:title]) if options[:title]
    message
  end
end
