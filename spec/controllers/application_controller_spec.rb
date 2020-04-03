RSpec.describe ApplicationController do
  render_views
  controller do
    def index
      raise ActionController::InvalidAuthenticityToken
    end
  end

  describe "handling InvalidAuthenticityToken exceptions" do
    it "renders the invalid session template" do
      get :index
      expect(response.body).to include("Sorry, there was a problem")
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
