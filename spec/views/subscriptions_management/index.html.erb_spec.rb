RSpec.describe "subscriptions_management/index" do
  before do
    assign(:subscriber, {})
    allow(view).to receive(:use_govuk_account_layout?).and_return(false)
    allow(view).to receive(:is_single_page_subscription?).and_return(false)
  end

  %w[daily weekly immediately].each do |frequency|
    context "for a #{frequency} subscription" do
      it "renders a flash message" do
        subscription = {
          "id" => 1,
          "frequency" => frequency,
          "created_at" => Time.zone.now.to_s,
          "subscriber_list" => {
            "title" => "A thing to subscribe to",
          },
        }

        assign(:subscriptions, { subscription["id"] => subscription })
        flash[:subscription] = { "id" => subscription["id"] }

        render

        expect(rendered).to have_content(
          I18n.t!("subscriptions_management.index.flashes.subscription", title: subscription["subscriber_list"]["title"]),
        )
        expect(rendered).to have_css("a[href='#{confirm_unsubscribe_path(subscription['id'])}'] .govuk-visually-hidden", text: "from #{subscription['subscriber_list']['title']}")
        expect(rendered).to have_css("a[href='#{update_frequency_path(subscription['id'])}'] .govuk-visually-hidden", text: "about #{subscription['subscriber_list']['title']}")
        expect(rendered).to have_content("Change how often you get emails about #{subscription['subscriber_list']['title']}", normalize_ws: true)
        expect(rendered).to have_content("Unsubscribe from #{subscription['subscriber_list']['title']}", normalize_ws: true)
      end
    end
  end

  context "if the subscription is not found" do
    it "does not render a flash" do
      assign(:subscriptions, {})
      flash[:subscription] = { "id" => 1 }

      render
      expect(rendered).to_not have_content("You’ve subscribed to emails about")
    end
  end
end
