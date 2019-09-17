module ApplicationHelper
  def title(text, params = {})
    render 'govuk_publishing_components/components/title', { title: text }.merge(params)
  end

  def live_content_item?(content_item)
    content_item['phase'] == 'live'
  end
end
