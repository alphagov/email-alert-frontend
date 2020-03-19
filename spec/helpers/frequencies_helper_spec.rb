RSpec.describe FrequenciesHelper do
  describe "#frequency_options" do
    it "returns empty options without a topic_id" do
      options = frequency_options(nil)
      expect(options).to eq({})
    end

    it "returns empty options non listed topic_id" do
      options = frequency_options("not-listed-topic-id")
      expect(options).to eq({})
    end

    it "returns default options for a listed topic_id" do
      options = frequency_options("coronavirus-covid-19-uk-government-response")
      expect(options).to eq({ checked_frequency: "daily" })
    end
  end

  describe "#frequencies" do
    it "returns default frequencies without options" do
      expect(frequencies).to eq([
        {
          value: :immediately,
          text: "As soon as they happen",
          checked: false,
        },
        {
          value: :daily,
          text: "Once a day",
          checked: false,
        },
        {
          value: :weekly,
          text: "Once a week",
          checked: false,
        },
      ])
    end

    it "returns default frequencies with options" do
      expect(frequencies({ checked_frequency: "daily" })).to eq([
        {
          value: :immediately,
          text: "As soon as they happen",
          checked: false,
        },
        {
          value: :daily,
          text: "Once a day",
          checked: true,
        },
        {
          value: :weekly,
          text: "Once a week",
          checked: false,
        },
      ])
    end
  end
end
