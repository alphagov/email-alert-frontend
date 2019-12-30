describe AuthToken do
  include TokenHelper

  describe "#data" do
    context "JWT token (legacy)" do
      it "returns the data hash when valid" do
        token = AuthToken.new(jwt_token(data: { a: "b" }))
        expect(token.data).to eq(a: "b")
      end

      it "returns nil after the expiry time" do
        token = AuthToken.new(jwt_token(expiry: 1.year.ago))
        expect(token.data).to be_nil
      end

      it "returns nil if the token is invalid" do
        token = AuthToken.new("eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjp7ImEiOiJiIn0sImV4cCI6MTU3NjYwMzEzMCwiaWF0IjoxNTc2NjAyODMwLCJpc3MiOiJodHRwczovL3d3dy5nb3YudWsifQ.Y6CjmaHAu6RSkEHySYQhuINuYQwj9Kpb8Zs6PzlBVv9")
        expect(token.data).to be_nil
      end
    end

    context "ActiveSupport token" do
      it "returns the data hash when valid" do
        token = AuthToken.new(encrypt_and_sign_token(data: { a: "b" }))
        expect(token.data).to eq(a: "b")
      end

      it "returns nil after the expiry time" do
        token = AuthToken.new(encrypt_and_sign_token(expiry: 0))
        expect(token.data).to be_nil
      end

      it "returns nil if the token is malformed" do
        token = AuthToken.new("foo")
        expect(token.data).to be_nil
      end

      it "returns nil if the token is invalid" do
        token = AuthToken.new("1HmD8E9iHE7LWl6vT+dfRiKoxX9fU/BY--0MJPSBtYJqtox940--q/zvsHND7yFOeVsIdFbbIQ==")
        expect(token.data).to be_nil
      end
    end
  end
end
