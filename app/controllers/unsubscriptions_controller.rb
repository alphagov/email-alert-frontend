class UnsubscriptionsController < ApplicationController
  def confirm
    @subscription_uuid = uuid
    @title = title
  end

  def confirmed
  end

private

  def uuid
    params[:uuid]
  end

  def title
    params[:title]
  end
end
