class ErrorsController < ApplicationController
  def unprocessable_entity
    render status: :unprocessable_entity
  end
end
