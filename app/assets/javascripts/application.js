// from govuk_frontend_toolkit and not delivered by static as part of
// header-footer-only on deployed environments
//=require govuk/show-hide-content.js
//
// from govuk_publishing_components
//=require govuk_publishing_components/components/error-summary
;(function () {
  $('.js-hidden-submit').removeClass('js-hidden-submit')
  $('.no-js-panel').removeClass('no-js-panel')
  $('.no-js-hidden-submit').addClass('js-hidden-submit')
  $('.js-hidden-submit').attr('aria-hidden', 'false')
  var showHideContent = new GOVUK.ShowHideContent()
  showHideContent.init()
})()
