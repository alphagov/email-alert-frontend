/* eslint-env jasmine */
/* global GOVUK */

describe('EmailAnalytics', function () {
  'use strict'

  describe('when GOVUK.analytics is undefined', function () {
    beforeEach(function () {
      GOVUK.analytics = undefined
    })

    describe('trackEvent', function () {
      it('does not raise an error', function () {
        var emailAnalytics = new GOVUK.Modules.EmailAnalytics()

        expect(emailAnalytics.trackEvent).not.toThrow()
      })
    })
  })

  describe('when GOVUK.analytics is defined', function () {
    beforeEach(function () {
      GOVUK.analytics = {
        trackEvent: function () {}
      }
    })

    describe('trackEvent', function () {
      it('forwards arguments to GOVUK.analytics', function () {
        spyOn(GOVUK.analytics, 'trackEvent')

        var emailAnalytics = new GOVUK.Modules.EmailAnalytics()

        emailAnalytics.trackEvent('category', 'action', {})

        expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
          'category', 'action', {})
      })
    })
  })
})
