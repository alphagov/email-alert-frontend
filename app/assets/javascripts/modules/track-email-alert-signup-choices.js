window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  'use strict'

  function TrackEmailAlertSignupChoices (element) {
    this.form = element
  }

  TrackEmailAlertSignupChoices.prototype.init = function () {
    this.form.addEventListener('submit', this.handleSubmit.bind(this))
  }

  TrackEmailAlertSignupChoices.prototype.handleSubmit = function (event) {
    var options
    var submittedForm = event.target
    var checkedOption = submittedForm.querySelector('input:checked')
    var category = submittedForm.getAttribute('data-track-category')
    var action = submittedForm.getAttribute('data-track-action')

    if (checkedOption) {
      var checkedOptionId = checkedOption.getAttribute('id')
      var checkedOptionLabel = submittedForm.querySelector('label[for="' + checkedOptionId + '"]').innerText

      var label = checkedOptionLabel.length
        ? checkedOptionLabel
        : checkedOption.value

      options = { transport: 'beacon', label: label }

      this.forwardToAnalytics(category, action, options)
    } else {
      options = { transport: 'beacon', label: '' }
      this.forwardToAnalytics(category, action, options)
    }
  }

  TrackEmailAlertSignupChoices.prototype.forwardToAnalytics = function () {
    if (!GOVUK.analytics || !GOVUK.analytics.trackEvent) { return }
    return GOVUK.analytics.trackEvent.apply(GOVUK, arguments)
  }

  Modules.TrackEmailAlertSignupChoices = TrackEmailAlertSignupChoices
})(window.GOVUK.Modules)
