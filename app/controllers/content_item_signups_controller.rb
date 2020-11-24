# This controller takes any content item and makes it possible to subscribe
# to alerts when documents linked to them are changed (taxons, orgs etc).
# This is in contrast to EmailAlertSignupsController, which takes a
# finder_email_signup content item.
class ContentItemSignupsController < ApplicationController
  include TaxonsHelper

  protect_from_forgery except: [:create]
  before_action :require_content_item_param
  before_action :handle_redirects
  before_action :validate_document_type

  def new
    if is_taxon?(@content_item) && taxon_children(@content_item).any?
      render "taxon"
    else
      render "confirm"
    end
  end

  def confirm; end

  def create
    if content_item.to_h.present?
      signup = ContentItemSubscriberList.new(content_item.to_h)
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_content_item_signup_path(link: content_item_path)
    end
  end

private

  PERMITTED_CONTENT_ITEMS = %w[taxon
                               organisation
                               ministerial_role
                               person
                               topic
                               topical_event
                               service_manual_topic
                               service_manual_service_standard].freeze

  def require_content_item_param
    unless valid_content_item_param?
      bad_request
    end
  end

  def valid_content_item_param?
    content_item_path.to_s.starts_with?("/") && URI.parse(content_item_path).relative?
  rescue URI::InvalidURIError
    false
  end

  def content_item_path
    # Topic param left in for backwards compatibility.
    # Topic is the user-facing terminology for taxons. Expect the taxon base
    # path to be provided in a param of this name.
    params[:link] || params[:topic]
  end

  def content_item
    @content_item ||= GdsApi.content_store.content_item(content_item_path)
  end

  def handle_redirects
    if content_item["document_type"] == "redirect"
      destination_path = content_item.dig("redirects", 0, "destination")
      if destination_path.nil?
        redirect_to("/")
      else
        redirect_to(new_content_item_signup_path(topic: destination_path))
      end
      false
    end
  end

  def validate_document_type
    unless PERMITTED_CONTENT_ITEMS.include?(content_item["document_type"])
      bad_request
    end
  end
end
