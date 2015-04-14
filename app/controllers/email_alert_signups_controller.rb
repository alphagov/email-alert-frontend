
require 'gds_api/helpers'

class EmailAlertSignupsController < ApplicationController
  include GdsApi::Helpers

  def new
    @email_alert_signup = EmailAlertSignupPresenter.new(content_store.content_item!("/#{params[:base_path]}"))

    set_slimmer_dummy_artefact(breadcrumbs_for_slimmer(@email_alert_signup.breadcrumbs))
  end

private

  def breadcrumbs_for_slimmer(breadcrumbs)
    crumb = breadcrumbs.shift
    if breadcrumbs.any?
      crumb.merge(parent: build_breadcrumb(breadcrumbs))
    else
      crumb
    end
  end
end
