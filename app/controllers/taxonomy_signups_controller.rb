class TaxonomySignupsController < ApplicationController
  def new
    redirect_to '/' and return unless valid_query_param?

    load_taxon
    load_breadcrumbs
  end

  def confirm
    redirect_to '/' and return unless valid_query_param?

    load_taxon
    load_breadcrumbs
  end

  def create
    load_taxon
    signup = TaxonomySignup.new(@taxon.to_h)

    if signup.save
      redirect_to signup.subscription_management_url
    else
      redirect_to confirm_taxonomy_signup_path(topic: taxon_path)
    end
  end

private

  def valid_query_param?
    taxon_path.present?
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

  def load_breadcrumbs
    @breadcrumbs = GovukNavigationHelpers::NavigationHelper.new(@taxon)
      .taxon_breadcrumbs[:breadcrumbs]
    @breadcrumbs.last.merge!(is_current_page: false, url: @taxon['base_path'])
    @breadcrumbs << { title: 'Get email alerts', is_current_page: true }
  end
end
