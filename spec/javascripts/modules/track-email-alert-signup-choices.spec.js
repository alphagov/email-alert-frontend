/* eslint-env jasmine */
/* global GOVUK Event $ */

describe('Email alert sign up tracking', function () {
  'use strict'

  var container, tracker

  beforeEach(function () {
    container = document.createElement('div')
    container.innerHTML =
        '<form onsubmit="event.preventDefault()" data-module="track-email-alert-signup-choices" data-track-action="action-name" data-track-category="category-name">' +
          '<div>' +
            '<input name="sector_business_area[]" id="construction" type="radio" value="construction">' +
            '<label for="construction">Construction label</label>' +
          '</div>' +
          '<div>' +
            '<input name="sector_business_area[]" id="accommodation" type="radio" value="accommodation">' +
           '<label for="accommodation">Accommodation label</label>' +
          '</div>' +
          '<div>' +
            '<input name="sector_business_area[]" type="radio" value="furniture">' +
          '</div>' +
          '<button type="submit">Next</button>' +
        '</form>'

    document.body.appendChild(container)
    var element = document.querySelector('[data-module="track-email-alert-signup-choices"]')
    tracker = new GOVUK.Modules.TrackEmailAlertSignupChoices()
    tracker.start($(element))
  })

  afterEach(function () {
    document.body.removeChild(container)
  })

  describe('trackEvent', function () {
    beforeEach(function () {
      GOVUK.analytics = {
        trackEvent: function () {}
      }
    })

    it('tracks selected radio buttons when clicking submit', function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      tracker.form.querySelector('input[value="accommodation"]').click()
      tracker.form.dispatchEvent(new Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'category-name', 'action-name', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('reports label as empty string when no option has been selected', function () {
      spyOn(GOVUK.analytics, 'trackEvent')

      tracker.form.dispatchEvent(new window.Event('submit'))

      expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
        'category-name', 'action-name', { transport: 'beacon', label: '' }
      )
    })
  })
})
