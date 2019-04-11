class TaxonomySignupsController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :require_taxon_param
  before_action :validate_taxon_document_type
  helper_method :child_taxons
  helper_method :estimated_email_frequency

  def new; end

  def confirm; end

  def create
    signup = ContentItemSubscriberList.new(taxon.to_h)

    if signup.has_content_item?
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(topic: taxon_path)
    end
  end

  def child_taxons
    taxon['links']
      .fetch('child_taxons', [])
      .reject { |taxon| taxon['phase'] == 'alpha' }
  end

private

  def require_taxon_param
    unless valid_taxon_param?
      redirect_to '/'
      false
    end
  end

  def valid_taxon_param?
    taxon_path.to_s.starts_with?('/') && URI.parse(taxon_path).relative?
  rescue URI::InvalidURIError
    false
  end

  def taxon_path
    # Topic is the user-facing terminology for taxons. Expect the taxon base
    # path to be provided in a param of this name.
    params[:topic]
  end

  def taxon
    @taxon ||= EmailAlertFrontend
      .services(:content_store)
      .content_item(taxon_path)
  end

  def validate_taxon_document_type
    unless taxon['document_type'] == 'taxon'
      redirect_to '/'
      false
    end
  end

  def estimated_email_frequency
    EmailVolume::WeeklyEmailVolume.new(taxon).estimate
  end
end
