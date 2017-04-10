class TaxonomySignupsController < ApplicationController
  protect_from_forgery except: [:create]
  before_action :require_taxon_param
  before_action :load_taxon
  before_action :validate_taxon_document_type

  def new
    load_breadcrumbs
  end

  def confirm
    load_estimated_email_frequency
    load_breadcrumbs
  end

  def create
    signup = TaxonomySignup.new(@taxon.to_h)

    if signup.save
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(topic: taxon_path)
    end
  end

private

  def require_taxon_param
    redirect_to '/' and return unless valid_taxon_param?
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

  def load_taxon
    @taxon ||= EmailAlertFrontend
      .services(:content_store)
      .content_item(taxon_path)
  end

  def validate_taxon_document_type
    redirect_to '/' and return unless @taxon['document_type'] == 'taxon'
  end

  def load_breadcrumbs
    @breadcrumbs = GovukNavigationHelpers::NavigationHelper.new(@taxon)
      .taxon_breadcrumbs[:breadcrumbs]
    @breadcrumbs.last.merge!(is_current_page: false, url: @taxon['base_path'])
    @breadcrumbs << { title: 'Get email alerts', is_current_page: true }
  end

  def load_estimated_email_frequency
    @estimated_email_frequency = WeeklyEmailVolume.new(@taxon).estimate
  end
end
