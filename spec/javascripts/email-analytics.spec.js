/* eslint-env jasmine, jquery */

describe('EmailAnalytics', function () {
  'use strict'

  var GOVUK = window.GOVUK || {}

  describe('when GOVUK.analytics is undefined', function () {
    beforeEach(function () {
      GOVUK.analytics = undefined
    })

    describe('trackEvent', function () {
      it('does not raise an error', function () {
        expect(GOVUK.EmailAnalytics.trackEvent).not.toThrow()
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
        GOVUK.EmailAnalytics.trackEvent('category', 'action', {})
        expect(GOVUK.analytics.trackEvent).toHaveBeenCalledWith(
          'category', 'action', {})
      })
    })
  })
})
