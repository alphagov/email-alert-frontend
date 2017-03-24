Before do
  @mock_email_alert_api = instance_double(GdsApi::EmailAlertApi)
  EmailAlertFrontend.register_service(:email_alert_api, @mock_email_alert_api)
end
