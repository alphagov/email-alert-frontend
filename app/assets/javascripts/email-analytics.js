(function (global, GOVUK) {
  'use strict'

  window.GOVUK = window.GOVUK || {}

  function canTrack () {
    return !!GOVUK.analytics
  }

  // The EmailAnalytics module is a wrapper around GOVUK.analytics
  GOVUK.EmailAnalytics = {
    trackEvent: function trackEvent () {
      if (!canTrack() || !GOVUK.analytics.trackEvent) { return }
      return GOVUK.analytics.trackEvent.apply(GOVUK, arguments)
    }
  }
})(window, window.GOVUK)
