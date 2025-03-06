GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Email Alert Frontend Component Guide"
  c.application_stylesheet = "application"
  c.custom_css_exclude_list = %w[
    govuk_publishing_components/components/_button.css
    govuk_publishing_components/components/_cookie-banner.css
    govuk_publishing_components/components/_feedback.css
    govuk_publishing_components/components/_input.css
    govuk_publishing_components/components/_label.css
    govuk_publishing_components/components/_layout-footer.css
    govuk_publishing_components/components/_layout-for-public.css
    govuk_publishing_components/components/_layout-header.css
    govuk_publishing_components/components/_layout-super-navigation-header.css
    govuk_publishing_components/components/_search-with-autocomplete.css
    govuk_publishing_components/components/_skip-link.css
  ]
end
