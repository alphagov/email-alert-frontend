# This controller takes any content item and makes it possible to subscribe
# to alerts when documents linked to them are changed (taxons, orgs etc).
# This is in contrast to EmailAlertSignupsController, which takes a
# finder_email_signup content item.
class ContentItemSignupsController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :require_content_item_param
  before_action :handle_redirects
  before_action :validate_document_type
  helper_method :weekly_email_volume_estimate

  def new
    @subscription = ContentItemSubscriptionPresenter.new(@content_item)

    if @subscription.child_taxons.present?
      render "new"
    else
      render "confirm"
    end
  end

  def confirm
    @subscription = ContentItemSubscriptionPresenter.new(content_item)
  end

  def create
    signup = ContentItemSubscriberList.new(content_item.to_h)

    if signup.has_content_item?
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_content_item_signup_path(link: content_item_path)
    end
  end

private

  PERMITTED_CONTENT_ITEMS = %w[taxon organisation ministerial_role person topical_event].freeze

  def require_content_item_param
    unless valid_content_item_param?
      redirect_to "/"
      false
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
    @content_item ||= EmailAlertFrontend
      .services(:content_store)
      .content_item(content_item_path)
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
      redirect_to "/"
      false
    end
  end

  def weekly_email_volume_estimate
    EmailVolume::WeeklyEmailVolume.new(content_item).estimate
  end
end
