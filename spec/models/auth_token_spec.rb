describe AuthToken do
  include TokenHelper

  describe "#data" do
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
