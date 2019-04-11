# This controller takes any content item and makes it possible to subscribe
# to alerts when documents linked to them are changed (taxons, orgs etc).
# This is in contrast to EmailAlertSignupsController, which takes a
# finder_email_signup content item.
class ContentItemSignupsController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :require_content_item_param
  before_action :validate_document_type
  helper_method :child_taxons
  helper_method :estimated_email_frequency

  def new; end

  def confirm; end

  def create
    signup = ContentItemSubscriberList.new(content_item.to_h)

    if signup.has_content_item?
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_content_item_signup_path(link: content_item_path)
    end
  end

private

  def require_content_item_param
    unless valid_content_item_param?
      redirect_to '/'
      false
    end
  end

  def valid_content_item_param?
    content_item_path.to_s.starts_with?('/') && URI.parse(content_item_path).relative?
  rescue URI::InvalidURIError
    false
  end

  def content_item_path
    # Topic param left in for backwards compatibility.
    # Topic is the user-facing terminology for taxons. Expect the taxon base
    # path to be provided in a param of this name.
    params[:link] || params[:topic]
  end

  def content_item
    @content_item ||= EmailAlertFrontend
      .services(:content_store)
      .content_item(content_item_path)
  end

  def validate_document_type
    unless content_item['document_type'] == 'taxon'
      redirect_to '/'
      false
    end
  end

  def estimated_email_frequency
    EmailVolume::WeeklyEmailVolume.new(content_item).estimate
  end

  def child_taxons
    return unless content_item['document_type'] == 'taxon'

    content_item['links']
      .fetch('child_taxons', [])
      .reject { |taxon| taxon['phase'] == 'alpha' }
  end
end
