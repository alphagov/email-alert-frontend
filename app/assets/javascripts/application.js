//=require govuk_publishing_components/components/error-summary
//=require govuk/show-hide-content.js
;(function () {
  $('.js-hidden-submit').removeClass('js-hidden-submit')
  $('.no-js-panel').removeClass('no-js-panel')
  $('.no-js-hidden-submit').addClass('js-hidden-submit')
  $('.js-hidden-submit').attr('aria-hidden', 'false')
  var showHideContent = new GOVUK.ShowHideContent()
  showHideContent.init()
})()
