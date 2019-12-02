module TokenHelper
  def jwt_token(data: {}, expiry: 5.minutes.from_now)
    token_data = {
      "data" => data,
      "exp" => expiry.to_i,
      "iat" => Time.now.to_i,
      "iss" => "https://www.gov.uk",
    }

    secret = Rails.application.secrets.email_alert_auth_token
    JWT.encode(token_data, secret, "HS256")
  end
end
