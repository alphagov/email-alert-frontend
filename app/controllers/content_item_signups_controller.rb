# This controller takes any content item and makes it possible to subscribe
# to alerts when documents linked to them are changed (taxons, orgs etc).
# This is in contrast to the EmailAlertSignupsController, which takes a
# finder_email_signup content item.
#  This controller also supports subscribing users to changes to the document itself
# (aka a content id based or single page list) if the paramater 'single_page_subscription'
# is present in the request.
# The govuk_account_signups controller also supports single page subscriptions, but it
# enforces the govuk account.

class ContentItemSignupsController < ApplicationController
  include TaxonsHelper

  protect_from_forgery except: [:create]
  before_action :assign_content_item
  before_action :handle_redirects
  before_action :assign_list_params

  def new
    if is_taxon_with_children?(@content_item)
      render "taxon"
    else
      render "confirm"
    end
  end

  def confirm
    if is_taxon_with_children?(@content_item) && params[:topic].nil?
      flash[:error] = t("content_item_signups.taxon.no_selection")
      render "taxon"
    end
  end

  def create
    slug = GdsApi.email_alert_api
                 .find_or_create_subscriber_list(@list_params)
                 .dig("subscriber_list", "slug")

    redirect_to new_subscription_path(topic_id: slug)
  end

private

  def handle_redirects
    return unless @content_item["document_type"] == "redirect"

    destination_path = @content_item.dig("redirects", 0, "destination")
    return error_not_found if destination_path.nil?

    redirect_to(new_content_item_signup_path(link: destination_path))
  end

  def assign_content_item
    # NOTE: the "topic" param has historically appeared in external links
    content_item_path = params[:topic] || params[:link]

    return bad_request unless content_item_path.to_s.starts_with?("/")
    return bad_request unless URI.parse(content_item_path).relative?

    @content_item ||= GdsApi.content_store.content_item(content_item_path)
  rescue URI::InvalidURIError
    bad_request
  end

  def assign_list_params
    @list_params = params_service.call(@content_item.to_h)
  rescue SubscriberListParams::GenerateLinksBasedListParamsService::UnsupportedContentItemError
    bad_request
  end

  def params_service
    if sign_up_to_content_id_based_subscription?
      SubscriberListParams::GenerateSinglePageListParamsService
    else
      SubscriberListParams::GenerateLinksBasedListParamsService
    end
  end

  def sign_up_to_content_id_based_subscription?
    params[:single_page_subscription] == "true"
  end
  helper_method :sign_up_to_content_id_based_subscription?
end
