GovukPublishingComponents.configure do |c|
  c.component_guide_title = "Email Alert Frontend Component Guide"
  c.application_stylesheet = "application"
  c.custom_css_exclude_list = %w[
    button
    cookie-banner
    feedback
    input
    label
    layout-footer
    layout-for-public
    layout-header
    layout-super-navigation-header
    search-with-autocomplete
    skip-link
  ]
end
