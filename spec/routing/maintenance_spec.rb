RSpec.describe "Maintenance Page" do
  context "when the maintenance variable is set" do
    before do
      Rails.application.config.maintenance_mode = true
      Rails.application.reload_routes!
    end

    after do
      Rails.application.config.maintenance_mode = false
      Rails.application.reload_routes!
    end

    it "routes to the maintenance controller" do
      expect(get("/email/authenticate")).to route_to(controller: "maintenance", action: "show", "": "email/authenticate")
    end

    it "routes to the maintenance controller" do
      expect(post("/email/authenticate")).to route_to(controller: "maintenance", action: "show", "": "email/authenticate")
    end
  end

  context "when the maintenance variable is not set" do
    it "routes to the usual controller" do
      expect(get("/email/manage")).to route_to(controller: "subscriptions_management", action: "index")
    end
  end
end
