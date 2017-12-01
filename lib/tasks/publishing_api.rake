require 'gds_api/publishing_api_v2'
require 'gds_api/publishing_api/special_route_publisher'

namespace :publishing_api do
  desc "Force claim the email-signup route"
  task publish_email_signup_routes_with_override: :environment do
    logger = Logger.new(STDOUT)

    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )

    endpoint = publishing_api.options[:endpoint_url]
    publishing_api.put_json("#{endpoint}/paths/email-signup", publishing_app: "email-alert-frontend", override_existing: true)
  end

  desc "Publish email signup page for taxonomy"
  task publish_email_signup_page: :environment do
    logger = Logger.new(STDOUT)

    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )

    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    special_route_publisher.publish(
      content_id: "e3bf851b-5df7-441b-8813-f0ec849da35f",
      title: "Get email alerts",
      description: "",
      base_path: "/email-signup",
      type: "exact",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )

    special_route_publisher.publish(
      content_id: "eb5fad51-f346-4365-be4a-ebc1b25b88f8",
      title: "Get email alerts",
      description: "",
      base_path: "/email-signup/confirm",
      type: "exact",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )
  end

  desc "Publish /email/unsubscribe prefix route"
  task publish_email_unsubscribe_prefix: :environment do
    logger = Logger.new(STDOUT)

    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example'
    )

    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    special_route_publisher.publish(
      content_id: "ea8a4639-fd68-4e09-8886-dc4c8f4dab7a",
      title: "Email unsubscribe",
      description: "Prefix route to allow users to unsubscribe from emails",
      base_path: "/email/unsubscribe",
      type: "prefix",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )
  end
end
