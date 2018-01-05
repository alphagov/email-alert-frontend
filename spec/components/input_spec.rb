require 'rails_helper'

describe "Input", type: :view do
  def render_component(locals)
    render file: "components/_input", locals: locals
  end

  it "fails to render when no data is given" do
    assert_raises do
      render_component({})
    end
  end

  it "renders text input with name and label text" do
    render_component(
      label: { text: "What is your email address?" },
      name: "email-address",
    )

    assert_select ".app-c-input[type='text']"
    assert_select ".app-c-input[name='email-address']"

    assert_select ".gem-c-label", text: "What is your email address?"
  end

  it "sets the 'for' on the label to the input id" do
    render_component(name: "email-address")

    input = css_select(".app-c-input")
    input_id = input.attr("id").text

    assert_select ".gem-c-label__text[for='#{input_id}']"
  end

  it "sets the value when provided" do
    render_component(
      name: "email-address",
      value: "example@example.com",
    )

    assert_select ".app-c-input[value='example@example.com']"
  end

  context "when an error_message is provided" do
    before do
      render_component(
        name: "email-address",
        error_message: "Please enter a valid email address",
      )
    end

    it "renders the error message as the label's hint" do
      assert_select ".gem-c-label__hint", text: "Please enter a valid email address"
    end

    it "makes the label bold" do
      assert_select ".gem-c-label--bold"
    end

    it "sets the 'aria-describedby' on the input to the hint id" do
      hint = css_select(".gem-c-label__hint")
      hint_id = hint.attr("id").text

      assert_select ".app-c-input[aria-describedby='#{hint_id}']"
    end
  end

  context "when an error_message is not provided" do
    before { render_component(name: "email-address") }

    it "does not render the label's hint" do
      assert_select ".gem-c-label__hint", count: 0
    end

    it "does not make the label bold" do
      assert_select ".gem-c-label--bold", count: 0
    end

    it "does not set the 'aria-describedby' on the input" do
      input = css_select(".app-c-input")
      expect(input.attr("aria-describedby")).to be_nil
    end
  end
end
