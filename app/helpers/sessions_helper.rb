module SessionsHelper
  def authenticate_subscriber(subscriber_id, linked_to_govuk_account: false)
    session["authentication"] = {
      "subscriber_id" => subscriber_id,
      "linked_to_govuk_account" => linked_to_govuk_account,
    }
  end

  def deauthenticate_subscriber
    session["authentication"] = nil
  end
end
