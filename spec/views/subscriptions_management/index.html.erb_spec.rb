RSpec.describe "subscriptions_management/index" do
  before do
    assign(:subscriber, {})
  end

  %w[daily weekly immediately].each do |frequency|
    context "for a #{frequency} subscription" do
      it "renders a flash message" do
        subscription = {
          "id" => 1,
          "frequency" => frequency,
          "created_at" => Time.zone.now.to_s,
          "subscriber_list" => {},
        }

        assign(:subscriptions, { subscription["id"] => subscription })
        flash[:subscription] = { "message" => "message", "id" => subscription["id"] }

        render
        expect(rendered).to have_content("message")

        expect(rendered).to have_content(
          I18n.t!("subscriptions_management.index.flashes.subscription.#{frequency}"),
        )
      end
    end
  end

  context "if the subscription is not found" do
    it "does not render a flash" do
      assign(:subscriptions, {})
      flash[:subscription] = { "message" => "message", "id" => 1 }

      render
      expect(rendered).to_not have_content("message")
    end
  end
end
