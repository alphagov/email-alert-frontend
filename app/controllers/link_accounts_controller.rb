class LinkAccountsController < ApplicationController
  include GovukPersonalisation::ControllerConcern
  include AccountHelper

  def show
    head :not_found and return unless govuk_account_auth_enabled?

    @link_or_sign_in = logged_in? ? "signed_in" : "signed_out"
  end
end
