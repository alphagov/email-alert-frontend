RSpec.describe ContentItemSignupsController do
  include GdsApi::TestHelpers::ContentStore

  shared_examples "router for redirects" do
    it "follows a redirect for an unpublished content item" do
      stub_content_store_has_item(
        "/magical/broomsticks",
        document_type: "redirect",
        redirects: [{ destination: "/cleaning/broomsticks" }],
      )

      make_request(topic: "/magical/broomsticks")
      expected_path = new_content_item_signup_path(topic: "/cleaning/broomsticks")
      expect(response).to redirect_to(expected_path)
    end

    it "returns a 404 if there is no destination path" do
      stub_content_store_has_item("/magical/broomsticks", document_type: "redirect")
      make_request(topic: "/magical/broomsticks")
      expect(response).to have_http_status(:not_found)
    end
  end

  shared_examples "proxy to content store" do
    it "returns a 400 if neither link nor topic are given" do
      make_request(bad_param: "/education/some-rando-item")
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 if the content item path is invalid" do
      make_request(topic: "/with unencoded spaces")
      expect(response).to have_http_status(:bad_request)

      make_request(topic: ["/a"])
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 when the content store returns a bad request response" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 400, headers: {})

      make_request(topic: base_path)
      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 403 when the user is not authorised" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 403, headers: {})

      make_request(topic: base_path)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns a 404 if the content item is not found" do
      stub_content_store_does_not_have_item("/education/some-rando-item")
      make_request(topic: "/education/some-rando-item")
      expect(response).to have_http_status(:not_found)
    end

    it "returns a 410 if the content item is unpublished" do
      stub_content_store_has_gone_item("/taxon-is-gone")
      make_request(topic: "/taxon-is-gone")
      expect(response).to have_http_status(:gone)
    end
  end

  shared_examples "limited to certain types" do
    it "returns a 400 if the content item is not supported" do
      stub_content_store_has_item("/cma-cases", document_type: "finder")
      make_request(topic: "/cma-cases")
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "#new" do
    def make_request(params)
      get :new, params: params
    end

    it_behaves_like "proxy to content store"
    it_behaves_like "router for redirects"
    it_behaves_like "limited to certain types"
  end

  describe "#confirm" do
    def make_request(params)
      get :confirm, params: params
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
  end
end
