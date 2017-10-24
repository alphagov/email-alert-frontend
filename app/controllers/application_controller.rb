class ApplicationController < ActionController::Base
  include Slimmer::Template
  include Slimmer::GovukComponents

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from GdsApi::HTTPNotFound, with: :error_not_found
  rescue_from GdsApi::HTTPGone, with: :gone

private

  def error_not_found
    render status: :not_found, plain: "404 error not found"
  end

  def gone
    render status: :gone, plain: "410 gone"
  end
end
