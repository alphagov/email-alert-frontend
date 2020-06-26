class VerifySubscriberEmailService < ApplicationService
  include Rails.application.routes.url_helpers

  def initialize(address:)
    @address = address
  end

  def call
    email_alert_api.send_subscriber_verification_email(
      address: @address,
      destination: process_sign_in_token_path,
    )
  rescue GdsApi::HTTPNotFound
    # User isn't subscribed, but we carry on as if they were so we
    # don't reveal this information.
    nil
  end

private

  attr_reader :address

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api_with_no_caching)
  end
end
