Before('@mock-email-alert-api') do
  mock_email_alert_api = double
  EmailAlertFrontend.register_service(:email_alert_api, mock_email_alert_api)
end
