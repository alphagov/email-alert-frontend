require 'rails_helper'

RSpec.describe "subscribing", type: :feature do
  context "successfully" do
    it "renders the success page" do
      visit "/email/subscriptions/new?topic_id=test135"
      fill_in :address, with: "test@test.com"
      click_button "Subscribe"
      expect(page).to have_content("Subscription successfully created")
    end
  end
end
