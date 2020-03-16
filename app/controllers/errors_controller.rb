class ErrorsController < ApplicationController
  def error_400
    render status: :bad_request
  end

  def error_403
    render status: :forbidden
  end

  def error_404
    render status: :not_found
  end

  def error_422
    render status: :unprocessable_entity
  end

  def error_500
    render status: :internal_server_error
  end

  def error_503
    render status: :service_unavailable
  end
end
