window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (global, GOVUK) {
  'use strict'

  var $ = global.jQuery

  GOVUK.Modules.TrackEmailAlertSignupChoices = function () {
    this.start = function (element) {
      track(element)
    }

    function track (element) {
      element.on('submit', function (event) {
        var $checkedOption, eventLabel, options
        var $submittedForm = $(event.target)
        var $checkedOptions = $submittedForm.find('input:checked')
        var category = $submittedForm.data('track-category')
        var action = $submittedForm.data('track-action')

        if ($checkedOptions.length) {
          $checkedOptions.each(function (index) {
            $checkedOption = $(this)
            var checkedOptionId = $checkedOption.attr('id')
            var checkedOptionLabel = $submittedForm.find('label[for="' + checkedOptionId + '"]').text().trim()
            eventLabel = checkedOptionLabel.length
              ? checkedOptionLabel
              : $checkedOption.val()

            options = { transport: 'beacon', label: eventLabel }

            GOVUK.EmailAnalytics.trackEvent(category, action, options)
          })
        } else {
          options = { transport: 'beacon', label: '' }

          GOVUK.EmailAnalytics.trackEvent(category, action, options)
        }
      })
    }
  }
})(window, window.GOVUK)
