class EmailAlertSignupsController < ApplicationController
  def new
    set_slimmer_dummy_artefact(breadcrumbs_for_slimmer(email_alert_signup.breadcrumbs))
  end

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

  def content_store
    EmailAlertFrontend.services(:content_store)
  end

  def email_alert_signup
    @email_alert_signup ||= EmailAlertSignup.new(content_store.content_item!("/#{params[:base_path]}"))
  end
  helper_method :email_alert_signup
end
