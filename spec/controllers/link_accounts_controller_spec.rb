RSpec.describe LinkAccountsController do
  include GovukPersonalisation::TestHelpers::Requests

  context "When GOV.UK accounts is not enabled" do
    describe "GET /email/manage/things-are-changing" do
      it "returns 404" do
        get :show
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context "When GOV.UK accounts is enabled" do
    render_views

    around do |example|
      ClimateControl.modify FEATURE_FLAG_GOVUK_ACCOUNT: "enabled" do
        example.run
      end
    end

    describe "GET /email/manage/things-are-changing" do
      before { get :show }

      let(:html) { Nokogiri.parse(response.body) }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "has the expected title" do
        expect(html.title).to eq("#{I18n.t('link_accounts.things_are_changing.heading')} - GOV.UK")
      end

      it "has the expected heading" do
        expect(html.css("h1").text).to eq(I18n.t("link_accounts.things_are_changing.heading"))
      end

      it "renders a button with the correct tracking category" do
        expect(html.at(".govuk-button").attr("data-track-category")).to eq("things_are_changing")
      end

      it "renders a button with the correct data module" do
        expect(html.at(".govuk-button").attr("data-module")).to eq("auto-track-event")
      end

      describe "when logged out" do
        it "renders logged out content on the button" do
          expect(html.at(".govuk-button").text).to eq(I18n.t("link_accounts.things_are_changing.action_button.signed_out"))
        end

        it "contains process_govuk_account_path as the form action" do
          expect(html.at("form")["action"]).to eq(process_govuk_account_path)
        end

        it "renders logged out tracking values on the button" do
          expect(html.at(".govuk-button").attr("data-track-action")).to eq(I18n.t("link_accounts.things_are_changing.tracking.action_button.signed_out"))
        end
      end

      describe "when logged in" do
        before do
          mock_logged_in_session("new-session-id")
          get :show
        end

        it "renders logged in content on the button" do
          expect(html.at(".govuk-button").text).to eq(I18n.t("link_accounts.things_are_changing.action_button.signed_in"))
        end

        it "contains process_govuk_account_path as the form action" do
          expect(html.at("form")["action"]).to eq(process_govuk_account_path)
        end

        it "renders logged in tracking values on the button" do
          expect(html.at(".govuk-button").attr("data-track-action")).to eq(I18n.t("link_accounts.things_are_changing.tracking.action_button.signed_in"))
        end
      end
    end
  end
end
