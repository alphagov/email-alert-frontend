class TaxonomySignupsController < ApplicationController
  def new
    redirect_to '/' and return unless params[:paths].present?

    # Only handle one taxon path for now - multiple signups may be handled in
    # future.
    taxon_path = params[:paths].first
    @taxon = EmailAlertFrontend.services(:content_store).content_item(taxon_path)
    @breadcrumbs = GovukNavigationHelpers::NavigationHelper.new(@taxon)
      .taxon_breadcrumbs[:breadcrumbs]
  end

  def confirm
    redirect_to '/' and return unless params[:paths].present?

    # Only handle one taxon path for now - multiple signups may be handled in
    # future.
    taxon_path = params[:paths].first
    @taxon = EmailAlertFrontend.services(:content_store).content_item(taxon_path)
    @breadcrumbs = GovukNavigationHelpers::NavigationHelper.new(@taxon)
      .taxon_breadcrumbs[:breadcrumbs]
  end

  def create
    @taxon = EmailAlertFrontend.services(:content_store).content_item(params[:taxon_path])
    signup = TaxonomySignup.new(@taxon.to_h)

    if signup.save
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(paths: [params[:taxon_path]])
    end
  end
end
