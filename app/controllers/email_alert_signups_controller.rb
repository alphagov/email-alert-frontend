require 'gds_api/helpers'

class EmailAlertSignupsController < ApplicationController
  include GdsApi::Helpers

  def new
    @email_alert_signup = EmailAlertSignupPresenter.new(content_store.content_item!("/#{params[:base_path]}"))
  end
end
