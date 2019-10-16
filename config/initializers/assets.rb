Rails.application.config.assets.precompile += %w(
  application.js
  application.css
  print.css
)

Rails.application.config.assets.prefix = "/email-alert-frontend"

Rails.application.config.assets.version = "1.0"

Rails.application.config.assets.digest = true
