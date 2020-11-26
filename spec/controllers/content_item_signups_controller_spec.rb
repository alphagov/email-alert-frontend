RSpec.describe ContentItemSignupsController do
  include GdsApi::TestHelpers::ContentStore

  describe "redirection" do
    it "follows a redirect" do
      stub_content_store_has_item(
        "/magical/broomsticks",
        document_type: "redirect",
        content_id: SecureRandom.uuid,
        redirects: [{ destination: "/cleaning/broomsticks" }],
      )

      get :new, params: { topic: "/magical/broomsticks" }

      expect(response).to have_http_status(:found)
      expect(response.location).to eq "http://test.host/email-signup?topic=%2Fcleaning%2Fbroomsticks"
    end
    it "returns not found if there is no destination path" do
      stub_content_store_has_item(
        "/magical/broomsticks",
        document_type: "redirect",
        content_id: SecureRandom.uuid,
      )

      get :new, params: { topic: "/magical/broomsticks" }
      expect(response).to have_http_status(:not_found)
    end
  end

  shared_examples "handles bad input data correctly" do
    it "redirects to root if topic param is missing" do
      make_request(bad_param: "/education/some-rando-item")

      expect(response).to have_http_status(:bad_request)
    end

    it "redirects to root if topic param isn't a valid path" do
      get :new, params: { topic: "/with unencoded spaces" }

      expect(response).to have_http_status(:bad_request)
    end

    it "redirects to root if topic param isn't interpreted as a string" do
      get :new, params: { topic: ["/a"] }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 400 when the content store returns a bad request response" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 400, headers: {})

      get :new, params: { topic: base_path }

      expect(response).to have_http_status(:bad_request)
    end

    it "returns a 403 when the user is not authorised" do
      base_path = "/#{SecureRandom.hex}"
      url = content_store_endpoint + "/content#{base_path}"
      stub_request(:get, url).to_return(status: 403, headers: {})

      get :new, params: { topic: base_path }

      expect(response).to have_http_status(:forbidden)
    end

    it "errors if no taxon found" do
      stub_content_store_does_not_have_item("/education/some-rando-item")
      make_request(topic: "/education/some-rando-item")

      expect(response).to have_http_status(:not_found)
    end

    it "returns a 410 if taxon is gone" do
      stub_content_store_has_gone_item("/taxon-is-gone")
      make_request(topic: "/taxon-is-gone")

      expect(response).to have_http_status(:gone)
    end

    it "redirects to root unless the content item is a taxon" do
      stub_content_store_has_item("/cma-cases", document_type: "finder")
      make_request(topic: "/cma-cases")

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "#new" do
    def make_request(params)
      get :new, params: params
    end

    it_behaves_like "handles bad input data correctly"
  end

  describe "#confirm" do
    def make_request(params)
      get :confirm, params: params
    end

    it_behaves_like "handles bad input data correctly"
  end

  describe "#create" do
    def make_request(params)
      post :create, params: params
    end

    it_behaves_like "handles bad input data correctly"
  end
end
