class ApplicationController < ActionController::Base
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

  if ENV["BASIC_AUTH_USERNAME"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

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

  def authenticated?
    session["authentication"].present?
  end

  def authenticated_subscriber_id
    # session isn't a real hash and doesn't respond to dig
    session["authentication"]&.fetch("subscriber_id", nil)
  end
end
