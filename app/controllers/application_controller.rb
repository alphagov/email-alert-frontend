class ApplicationController < ActionController::Base
  include GovukPersonalisation::ControllerConcern

  include Slimmer::Template

  before_action :set_cache_control_header

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_token
  rescue_from GdsApi::HTTPClientError, with: :bad_request
  rescue_from GdsApi::HTTPNotFound, with: :error_not_found
  rescue_from GdsApi::HTTPForbidden, with: :forbidden
  rescue_from GdsApi::HTTPGone, with: :gone

  helper_method :authenticated?
  helper_method :authenticated_via_account?
  helper_method :use_govuk_account_layout?

  if ENV["BASIC_AUTH_USERNAME"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

  def authenticated?
    authenticated_via_account? || session["authentication"].present?
  end

  def authenticated_via_account?
    return false if account_session_header.blank?
    return @authenticated_via_account unless @authenticated_via_account.nil?

    api_response = GdsApi.email_alert_api.link_subscriber_to_govuk_account(govuk_account_session: account_session_header)
    session["authentication"] = nil
    set_account_session_header(api_response["govuk_account_session"])
    @authenticated_subscriber_id = api_response.dig("subscriber", "id")
    @authenticated_via_account = true
  rescue GdsApi::HTTPUnauthorized, GdsApi::HTTPForbidden
    logout!
    @authenticated_via_account = false
  end

  def use_govuk_account_layout?
    false
  end

  slimmer_template :gem_layout

private

  def set_cache_control_header
    response.cache_control[:private] = true
    response.cache_control[:extras] = %w[no-cache]
  end

  def invalid_token
    reset_session
    head :unprocessable_entity
  end

  def bad_request
    render status: :bad_request, plain: "400 bad request"
  end

  def error_not_found
    render status: :not_found, plain: "404 not found"
  end

  def forbidden
    render status: :forbidden, plain: "403 forbidden"
  end

  def gone
    render status: :gone, plain: "410 gone"
  end

  def require_authentication
    redirect_to :sign_in unless authenticated?
  end

  def authenticated_subscriber_id
    # session isn't a real hash and doesn't respond to dig
    @authenticated_subscriber_id ||= session["authentication"]&.fetch("subscriber_id", nil)
  end
end
