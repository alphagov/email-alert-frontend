class TaxonomySignupsController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :require_taxon_param
  before_action :validate_taxon_document_type

  def new; end

  def confirm
    load_estimated_email_frequency
  end

  def create
    signup = TaxonomySignup.new(taxon.to_h)

    if signup.save
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(topic: taxon_path)
    end
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

  def load_estimated_email_frequency
    @estimated_email_frequency = WeeklyEmailVolume.new(taxon).estimate
  end
end
