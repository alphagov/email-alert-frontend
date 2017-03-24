class TaxonomySignupsController < ApplicationController
  def new
    redirect_to '/' and return unless params[:paths].present?

    taxon_path = params[:paths].first
    load_taxon(taxon_path)
    load_breadcrumbs
  end

  def confirm
    redirect_to '/' and return unless params[:'taxon-list'].present?

    taxon_path = params[:'taxon-list']
    load_taxon(taxon_path)
    load_breadcrumbs
  end

  def create
    load_taxon(params[:taxon_path])
    signup = TaxonomySignup.new(@taxon.to_h)

    if signup.save
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(paths: [params[:taxon_path]])
    end
  end

private

  def load_taxon(taxon_path)
    @taxon = EmailAlertFrontend
      .services(:content_store)
      .content_item(taxon_path)
  end

  def load_breadcrumbs
    @breadcrumbs = GovukNavigationHelpers::NavigationHelper.new(@taxon)
      .taxon_breadcrumbs[:breadcrumbs]
    @breadcrumbs.last.merge!(is_current_page: false, url: @taxon['base_path'])
    @breadcrumbs << { title: 'Get email alerts', is_current_page: true }
  end
end
