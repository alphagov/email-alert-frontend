RSpec.describe "healthcheck path", type: :request do
  before do
    get "/healthcheck"
  end

  it "returns a 200 HTTP status" do
    expect(response).to have_http_status(:ok)
  end

  it "includes a status in the response body" do
    expect(JSON.parse(response.body)).to have_key("status")
  end
end
