require 'rails_helper'

describe "Confirmation Box", type: :view do
  def render_component(locals)
    render file: "components/_confirmation_box", locals: locals
  end

  it "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  it "renders confirmation box with heading" do
    render_component(heading: "Application complete")

    assert_select ".app-c-confirmation-box"
    assert_select ".app-c-confirmation-box__heading", text: "Application complete"
  end
end
