module TokenHelper
  def encrypt_and_sign_token(data: {}, expiry: 5.minutes, hash_digest_class: OpenSSL::Digest::SHA256)
    len = ActiveSupport::MessageEncryptor.key_len(AuthToken::CIPHER)
    secret = Rails.application.credentials.email_alert_auth_token
    key = ActiveSupport::KeyGenerator.new(secret, hash_digest_class:).generate_key("", len)
    crypt = ActiveSupport::MessageEncryptor.new(key, **AuthToken::OPTIONS)
    crypt.encrypt_and_sign(data, expires_in: expiry)
  end
end
