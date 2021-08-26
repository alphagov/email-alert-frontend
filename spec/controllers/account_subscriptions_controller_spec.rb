RSpec.describe AccountSubscriptionsController do
  include GovukContentSchemaExamples

  include GdsApi::TestHelpers::AccountApi
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi
  include GovukPersonalisation::TestHelpers::Requests

  context "When GOV.UK accounts is not enabled" do
    describe "GET /email/subscriptions/account" do
      it "returns 404" do
        get :new
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context "When GOV.UK accounts is enabled" do
    render_views

    let(:auth_uri) { "/sign-in" }
    let(:content_item) { govuk_content_schema_example("detailed_guide", "detailed_guide") }
    let(:base_path) { content_item["base_path"] }
    let(:html) { Nokogiri.parse(response.body) }

    around do |example|
      ClimateControl.modify FEATURE_FLAG_GOVUK_ACCOUNT: "enabled" do
        example.run
      end
    end

    before do
      stub_content_store_has_item(base_path, content_item.to_json)
    end

    describe "GET /email/subscriptions/account" do
      context "when logged in" do
        before do
          mock_logged_in_session("new-session-id")
          get :new, params: { link: base_path }
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end

        it "renders logged in content on the title" do
          expect(html.at("title").text).to eq("#{I18n.t('account_subscriptions.new.logged_in.title')} - GOV.UK")
        end

        it "renders logged in content on the header" do
          expect(html.at("h1").text).to eq(I18n.t("account_subscriptions.new.logged_in.heading"))
        end

        it "renders logged in content on the description" do
          expect(response.body).to include(I18n.t("account_subscriptions.new.logged_in.description"))
        end

        it "adds logged in tracking values to the button" do
          expect(html.at(".govuk-button")["data-track-action"]).to eq(I18n.t("account_subscriptions.new.logged_in.tracking"))
        end

        it "renders logged in content on the button" do
          expect(html.at(".govuk-button").text).to eq(I18n.t("account_subscriptions.new.logged_in.action_button_text"))
        end

        it "contains create_account_subscription_path as the form action" do
          expect(html.at("form")["action"]).to eq(create_account_subscription_path)
        end
      end

      context "when logged out" do
        before do
          stub_account_api_get_sign_in_url(
            redirect_path: new_account_subscription_path(base_path),
            level_of_authentication: "level0",
          )
          get :new, params: { link: base_path }
        end

        it "returns 400 if no link or topic parameter is present" do
          get :new
          expect(response).to have_http_status(:bad_request)
        end

        it "returns 200 if a link parameter is present" do
          expect(response).to have_http_status(:ok)
        end

        it "renders logged out content on the title" do
          expect(html.at("title").text).to eq("#{I18n.t('account_subscriptions.new.logged_out.title')} - GOV.UK")
        end

        it "renders logged out content on the header" do
          expect(html.at("h1").text).to eq(I18n.t("account_subscriptions.new.logged_out.heading"))
        end

        it "renders logged out content on the description" do
          expect(response.body).to include(I18n.t("account_subscriptions.new.logged_out.description"))
        end

        it "renders logged out content on the button" do
          expect(html.at(".govuk-button").text).to eq(I18n.t("account_subscriptions.new.logged_out.action_button_text"))
        end

        it "adds logged out tracking values to the button" do
          expect(html.at(".govuk-button")["data-track-action"]).to eq(I18n.t("account_subscriptions.new.logged_out.tracking"))
        end

        it "has form action pointing to authenticate endpoint" do
          expect(html.at("form")["action"]).to eq("/sign-in")
        end
      end
    end

    describe "POST /email/subscriptions/account" do
      context "when logged out" do
        before do
          get :create, params: { link: base_path }
        end

        it "returns 302" do
          expect(response).to have_http_status(:redirect)
        end

        it "sends the user to new_account_subscription_path" do
          response.should redirect_to(new_account_subscription_path({ link: base_path }))
        end
      end

      context "when logged in" do
        it "creates a subscriber list, links the subscription in accounts and redirects the user back to the content item" do
          mock_logged_in_session("new-session-id")
          stub_email_alert_api_creates_subscriber_list(
            {
              "title" => content_item["title"],
              "slug" => content_item["slug"],
              "links" => content_item["links"],
              "url" => content_item["url"],
            },
          )
          stub_account_api_put_email_subscription(name: content_item["content_id"], topic_slug: content_item["slug"])
          get :create, params: { link: base_path }
          expect(response).to redirect_to(base_path)
        end
      end
    end
  end
end
