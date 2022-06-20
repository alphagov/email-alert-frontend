describe AuthToken do
  include TokenHelper

  describe "#data" do
    it "returns the data hash when given a valid SHA256 token" do
      token = AuthToken.new(encrypt_and_sign_token(data: { a: "b" }, hash_digest_class: OpenSSL::Digest::SHA256))
      expect(token.data).to eq(a: "b")
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

  describe "#valid?" do
    it "returns false when given a SHA1 token" do
      token = AuthToken.new(encrypt_and_sign_token(data: { a: "b" }, hash_digest_class: OpenSSL::Digest::SHA1))
      expect(token.valid?).to be false
    end

    context "with a SHA256 token" do
      it "returns true when valid" do
        token = AuthToken.new(encrypt_and_sign_token(data: { a: "b" }, hash_digest_class: OpenSSL::Digest::SHA256))
        expect(token.valid?).to be true
      end

      it "returns false after the expiry time" do
        token = AuthToken.new(encrypt_and_sign_token(expiry: 0, hash_digest_class: OpenSSL::Digest::SHA256))
        expect(token.valid?).to be false
      end
    end
  end
end
