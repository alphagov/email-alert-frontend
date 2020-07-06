/* global GOVUK */

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function EmailAnalytics () {}

  EmailAnalytics.prototype.trackEvent = function () {
    if (!GOVUK.analytics || !GOVUK.analytics.trackEvent) { return }
    return GOVUK.analytics.trackEvent.apply(GOVUK, arguments)
  }

  Modules.EmailAnalytics = EmailAnalytics
})(window.GOVUK.Modules)
