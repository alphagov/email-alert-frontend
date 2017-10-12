RSpec.describe SignupPresenter do
  include FixturesHelper

  let(:signup_finder) { cma_cases_signup_content_item }

  subject do
    described_class.new(
      title: "title",
      description: "description",
      details: {
        beta: true,
        email_signup_choice: [
          {
            radio_button_name: "radio 0",
            body: "body 0",
          },
          {
            radio_button_name: "radio 1",
            body: "body 1",
          },
        ]
      }
    )
  end

  it "has some attributes" do
    expect(subject.page_title).to eq("title emails")
    expect(subject.name).to eq("title")
    expect(subject.body).to eq("description")
    expect(subject.beta?).to eq(true)
    expect(subject.choices?).to eq(true)
    expect(subject.choices).to eq [
      { radio_button_name: "radio 0", body: "body 0" },
      { radio_button_name: "radio 1", body: "body 1" },
    ]

    expect(subject.choice_name(0)).to eq("radio 0")
    expect(subject.choice_body(1)).to eq("body 1")
    expect(subject.target).to eq("#")
  end
end
