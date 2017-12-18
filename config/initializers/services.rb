require 'gds_api/email_alert_api'
require 'gds_api/content_store'

module EmailAlertFrontend
  def self.register_service(name, service)
    @services ||= {}

    @services[name] = service
  end

  def self.services(name)
    @services.fetch(name)
  end
end

EmailAlertFrontend.register_service(
  :email_alert_api,
  GdsApi::EmailAlertApi.new(
    Plek.new.find('email-alert-api'),
    bearer_token: ENV.fetch("EMAIL_ALERT_API_BEARER_TOKEN", "bearer_token")
  )
)
EmailAlertFrontend.register_service(:content_store, GdsApi::ContentStore.new(Plek.new.find('content-store')))
