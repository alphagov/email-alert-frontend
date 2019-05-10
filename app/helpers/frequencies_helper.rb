module FrequenciesHelper
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
