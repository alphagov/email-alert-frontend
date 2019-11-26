class AuthToken
  def initialize(jwt_token)
    @jwt_token = jwt_token
  end

  def valid?
    data.present?
  end

  def data
    @data ||= read_token
  end

private

  attr_reader :jwt_token

  def read_token
    payload, = JWT.decode(jwt_token, secret, true, algorithm: "HS256")
    payload.fetch("data").to_h.symbolize_keys
  rescue JWT::DecodeError
    nil
  end

  def secret
    Rails.application.secrets.email_alert_auth_token
  end
end
