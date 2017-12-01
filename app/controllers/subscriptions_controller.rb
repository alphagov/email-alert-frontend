class SubscriptionsController < ApplicationController
  def new
    @subscribable_id = params[:subscribable_id]
  end

  def create
    redirect_to subscription_path
  end

  def show; end
end
