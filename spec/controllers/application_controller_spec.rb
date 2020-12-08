RSpec.describe ApplicationController do
  controller do
    def index
      raise ActionController::InvalidAuthenticityToken
    end
  end

  describe "handling InvalidAuthenticityToken exceptions" do
    it "returns an unprocessable entity response" do
      get :index
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Cache-Control header" do
    it "sets it to 'private, no-cache'" do
      get :index
      expect(response.headers["Cache-Control"]).to eq("private, no-cache")
    end
  end
end
