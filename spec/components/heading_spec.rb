require 'rails_helper'

describe "Heading", type: :view do
  def render_component(locals)
    render file: "components/_heading", locals: locals
  end

  it "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  it "renders a heading correctly" do
    render_component(text: "Download documents")

    assert_select "h1.app-c-heading", text: "Download documents"
  end

  it "renders a different heading level" do
    render_component(text: "Original consultation", heading_level: 3)

    assert_select "h3.app-c-heading", text: "Original consultation"
  end

  it "has a specified id attribute" do
    render_component(text: "Consultation description", id: "custom-id")

    assert_select ".app-c-heading[id='custom-id']", text: "Consultation description"
  end
end
