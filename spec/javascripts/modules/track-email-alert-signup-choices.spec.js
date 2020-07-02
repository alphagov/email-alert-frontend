/* eslint-env jasmine, jquery */

var $ = window.jQuery

describe('Email alert sign up tracking', function () {
  var GOVUK = window.GOVUK || {};
  var tracker;
  var $element;

  beforeEach(function () {
    $element = $(
      '<div>' +
        '<form onsubmit="event.preventDefault()" data-track-action="action-name" data-track-category="category-name">' +
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
        '</form>' +
      '</div>'
    )

    tracker = new GOVUK.Modules.TrackEmailAlertSignupChoices();
    tracker.start($element)
  })

  afterEach(function () {
    GOVUK.EmailAnalytics.trackEvent.calls.reset()
  })

  describe('trackEvent', function () {
    it('tracks selected radio buttons when clicking submit', function () {
      spyOn(GOVUK.EmailAnalytics, 'trackEvent')

      $element.find('input[value="accommodation"]').trigger('click')
      $element.find('form').trigger('submit')

      expect(GOVUK.EmailAnalytics.trackEvent).toHaveBeenCalledWith(
        'category-name', 'action-name', { transport: 'beacon', label: 'Accommodation label' }
      )
    })

    it('reports label as empty string when no option has been selected', function () {
      spyOn(GOVUK.EmailAnalytics, 'trackEvent')

      $element.find('form').trigger('submit')

      expect(GOVUK.EmailAnalytics.trackEvent).toHaveBeenCalledWith(
        'category-name', 'action-name', { transport: 'beacon', label: '' }
      )
    })
  })
});
