require 'gds_api/publishing_api_v2'
require 'gds_api/publishing_api/special_route_publisher'

namespace :publishing_api do
  desc "Publish /email/unsubscribe prefix route"
  task publish_email_unsubscribe_prefix: :environment do
    logger = Logger.new(STDOUT)

    publishing_api = GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example')

    special_route_publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: logger,
      publishing_api: publishing_api
    )

    special_route_publisher.publish(
      content_id:"ea8a4639-fd68-4e09-8886-dc4c8f4dab7a",
      title: "Email unsubscribe",
      description: "Prefix route to allow users to unsubscribe from emails",
      base_path: "/email/unsubscribe",
      type: "prefix",
      publishing_app: 'email-alert-frontend',
      rendering_app: 'email-alert-frontend'
    )
  end
end
