module ApplicationHelper
  def title(text, params = {})
    render 'govuk_publishing_components/components/title', { title: text }.merge(params)
  end
end
