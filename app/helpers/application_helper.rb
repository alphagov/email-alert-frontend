module ApplicationHelper
  def govspeak
    render "govuk_publishing_components/components/govspeak" do
      yield
    end
  end

  def title(text, params = {})
    render 'govuk_publishing_components/components/title', { title: text }.merge(params)
  end
end
