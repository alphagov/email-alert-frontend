class EmailAlertSignupsController < ApplicationController
  protect_from_forgery except: [:create]

  def new; end

  def create
    if email_alert_signup.find_or_create
      redirect_to email_alert_signup.subscription_url
    else
      render action: "new"
    end
  end

private

  def email_alert_signup
    @email_alert_signup ||= EmailAlertSignup.new(
      GdsApi.content_store.content_item("/#{params[:base_path]}"),
    )
  end

  helper_method :email_alert_signup
end
