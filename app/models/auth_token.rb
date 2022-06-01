class AuthToken
  CIPHER = "aes-256-gcm".freeze
  OPTIONS = { cipher: CIPHER, serializer: JSON }.freeze

  def initialize(token)
    @token = token
  end

  def valid?
    data.present?
  end

  def data
    @data ||= read_token
  end

private

  attr_reader :token

  def read_token
    len = ActiveSupport::MessageEncryptor.key_len(CIPHER)
    key = ActiveSupport::KeyGenerator.new(secret).generate_key("", len)
    crypt = ActiveSupport::MessageEncryptor.new(key, **OPTIONS)
    key_sha1 = ActiveSupport::KeyGenerator.new(secret, hash_digest_class: OpenSSL::Digest::SHA1).generate_key("", len)
    crypt.rotate(key_sha1)
    decrypted_data = crypt.decrypt_and_verify(token)
    decrypted_data&.symbolize_keys
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    nil
  end

  def secret
    Rails.application.secrets.email_alert_auth_token
  end
end
