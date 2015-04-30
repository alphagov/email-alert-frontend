class EmailAlertSignupsController < ApplicationController
  protect_from_forgery except: [:create]

  def new
    set_slimmer_dummy_artefact(email_alert_signup.breadcrumbs)
  end

  def create
    if email_alert_signup.save
      redirect_to email_alert_signup.subscription_url
    else
      render action: 'new'
    end
  end

private

  def content_store
    EmailAlertFrontend.services(:content_store)
  end

  def email_alert_signup
    @email_alert_signup ||= EmailAlertSignup.new(content_store.content_item!("/#{params[:base_path]}"))
  end
  helper_method :email_alert_signup
end
