module SessionsHelper
  def authenticate_subscriber(subscriber_id)
    session["authentication"] = {
      "subscriber_id" => subscriber_id,
    }
  end

  def deauthenticate_subscriber
    session["authentication"] = nil
  end
end
