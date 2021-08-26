# This controller takes any content item and makes it possible to subscribe
# to alerts when documents linked to them are changed (taxons, orgs etc).
# This is in contrast to EmailAlertSignupsController, which takes a
# finder_email_signup content item.
class ContentItemSignupsController < ApplicationController
  include TaxonsHelper
  include ContentItemNotifications

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
end
