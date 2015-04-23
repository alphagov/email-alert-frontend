class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::SharedTemplates

  before_filter :set_slimmer_template

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from GdsApi::HTTPNotFound, with: :error_not_found

private

  def set_slimmer_template
    set_slimmer_headers(template: 'core_layout')
  end

  def error_not_found
    render status: :not_found, text: "404 error not found"
  end
end
