RSpec.describe ContentItemSignupsController do
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::EmailAlertApi

  render_views

  shared_examples "router for redirects" do
    it "follows a redirect for an unpublished content item" do
      stub_content_store_has_item(
        "/magical/broomsticks",
        document_type: "redirect",
        redirects: [{ destination: "/cleaning/broomsticks" }],
      )

      make_request(link: "/magical/broomsticks")
      expected_path = new_content_item_signup_path(link: "/cleaning/broomsticks")
      expect(response).to redirect_to(expected_path)
    end

    it "returns a 404 if there is no destination path" do
      stub_content_store_has_item("/magical/broomsticks", document_type: "redirect")
      make_request(link: "/magical/broomsticks")
      expect(response).to have_http_status(:not_found)
    end
  end

  shared_examples "proxy to content store" do
    it "returns a 400 if neither link nor topic are given" do
      make_request(bad_param: "/education/some-rando-item")
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 if the content item path is invalid" do
      make_request(link: "/with unencoded spaces")
      expect(response).to have_http_status(:bad_request)

      make_request(link: ["/a"])
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 when the content store returns a bad request response" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 400, headers: {})

      make_request(link: base_path)
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 403 when the user is not authorised" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 403, headers: {})

      make_request(link: base_path)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns a 404 if the content item is not found" do
      stub_content_store_does_not_have_item("/education/some-rando-item")
      make_request(link: "/education/some-rando-item")
      expect(response).to have_http_status(:not_found)
    end

    it "returns a 410 if the content item is unpublished" do
      stub_content_store_has_gone_item("/taxon-is-gone")
      make_request(link: "/taxon-is-gone")
      expect(response).to have_http_status(:gone)
    end
  end

  shared_examples "limited to certain types" do
    it "returns a 400 if the content item is not supported" do
      stub_content_store_has_item("/cma-cases", document_type: "finder")
      make_request(link: "/cma-cases")
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "#new" do
    def make_request(params)
      get :new, params: params
    end

    it "shows a page to confirm the subscription" do
      stub_content_store_has_item("/organisation", document_type: "organisation")
      make_request(link: "/organisation")
      expect(response.body).to include(I18n.t!("content_item_signups.confirm.title"))
    end

    it "shows a special page for taxons with children" do
      stub_content_store_has_item("/my-taxon",
                                  document_type: "taxon",
                                  links: { "child_taxons" => %w[child-taxon] })

      make_request(link: "/my-taxon")
      expect(response.body).to include(I18n.t!("content_item_signups.taxon.title"))
    end

    it_behaves_like "proxy to content store"
    it_behaves_like "router for redirects"
    it_behaves_like "limited to certain types"
  end

  describe "#confirm" do
    def make_request(params)
      get :confirm, params: params
    end

    it "shows an error if a taxon is not selected" do
      stub_content_store_has_item("/my-taxon",
                                  document_type: "taxon",
                                  links: { "child_taxons" => %w[child-taxon] })

      make_request(link: "/my-taxon")
      expect(response.body).to include(I18n.t!("content_item_signups.taxon.title"))
      expect(response.body).to include(I18n.t!("content_item_signups.taxon.no_selection"))
    end

    it_behaves_like "proxy to content store"
    it_behaves_like "router for redirects"
    it_behaves_like "limited to certain types"
  end

  describe "#create" do
    def make_request(params)
      post :create, params: params
    end

    it_behaves_like "proxy to content store"
    it_behaves_like "router for redirects"
    it_behaves_like "limited to certain types"

    it "creates a subscriber list for the content" do
      content_id = SecureRandom.uuid
      stub_content_store_has_item("/my-organisation", document_type: "organisation", content_id: content_id)

      stub_email_alert_api_does_not_have_subscriber_list("links" => { organisations: [content_id] })
      stub_email_alert_api_creates_subscriber_list("links" => { organisations: [content_id] }, "slug" => "my-list")

      make_request(link: "/my-organisation")
      expect(response).to redirect_to new_subscription_path(topic_id: "my-list")
    end

    it "uses an existing list if there is one" do
      content_id = SecureRandom.uuid
      stub_content_store_has_item("/my-organisation", document_type: "organisation", content_id: content_id)

      stub_email_alert_api_has_subscriber_list("links" => { organisations: [content_id] }, "slug" => "my-list")

      make_request(link: "/my-organisation")
      expect(response).to redirect_to new_subscription_path(topic_id: "my-list")
    end
  end
end
