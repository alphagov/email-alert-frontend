require 'gds_api/publishing_api_v2'
require 'gds_api/publishing_api/special_route_publisher'

namespace :publishing_api do
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

  desc "Publish /email/subscriptions prefix route"
  task publish_email_subscriptions_prefix: :environment do
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
      content_id: "1773511a-b3c9-4f37-8692-91a718d5b6ae",
      title: "Email - create subscription",
      description: "Prefix route to allow users to create email subscriptions",
      base_path: "/email/subscriptions",
      type: "prefix",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )
  end

  desc "Publish /email/authenticate prefix route"
  task publish_email_authenticate_prefix: :environment do
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
      content_id: "889e5a6f-d63b-4e10-8ffb-8d3959453285",
      title: "Email - authenticate",
      description: "Prefix route to allow authentication for email subscription management",
      base_path: "/email/authenticate",
      type: "prefix",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )
  end

  desc "Publish /email/manage prefix route"
  task publish_email_manage_prefix: :environment do
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
      content_id: "fb2f116f-09d2-4861-99d7-b6ea8168fe5d",
      title: "Email - manage",
      description: "Prefix route to allow email subscription management",
      base_path: "/email/manage",
      type: "prefix",
      publishing_app: "email-alert-frontend",
      rendering_app: "email-alert-frontend"
    )
  end
end
