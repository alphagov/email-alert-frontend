class SubscriptionsManagementController < ApplicationController
  before_action :require_authentication
  before_action :get_subscription_details
  before_action :set_back_url

  MISSING_EMAIL_ERROR = 'Please enter your email address.'.freeze
  INVALID_EMAIL_ERROR = 'That email address isn’t valid, or it’s already in use – check you’ve typed in your email address correctly.'.freeze

  def index; end

  def update_frequency
    @subscription_id = params.require(:id)

    return render status: :not_found, plain: '404 not found' if @subscriptions[@subscription_id].nil?

    @current_frequency = @subscriptions[@subscription_id]['frequency']
  end

  def change_frequency
    id = params.require(:id)

    email_alert_api.change_subscription(
      id: id,
      frequency: params.require(:new_frequency)
    )

    subscription_title = @subscriptions[id]['subscriber_list']['title']
    flash[:success] = "Your subscription to ‘#{subscription_title}’ has been updated"

    redirect_to list_subscriptions_path
  end

  def update_address
    @address = @subscriber['address']
  end

  def change_address
    @address = @subscriber['address']

    unless params[:new_address].present?
      flash.now[:error] = MISSING_EMAIL_ERROR
      return render :update_address
    end

    new_address = params.require(:new_address)

    email_alert_api.change_subscriber(
      id: subscriber_id,
      new_address: new_address
    )

    redirect_to list_subscriptions_path
  rescue GdsApi::HTTPUnprocessableEntity
    @new_address = new_address
    flash.now[:error] = INVALID_EMAIL_ERROR
    render :update_address
  end

  def confirm_unsubscribe_all; end

  def confirmed_unsubscribe_all
    begin
      email_alert_api.unsubscribe_subscriber(subscriber_id)
    rescue GdsApi::HTTPNotFound
      # The user has already unsubscribed.
      nil
    end
  end

private

  def subscriber_id
    session['authentication']['subscriber_id']
  end

  def get_subscription_details
    subscription_details = email_alert_api.get_subscriptions(
      id: subscriber_id
    )

    @subscriber = subscription_details['subscriber']
    @subscriptions = {}

    subscription_details['subscriptions'].each do |subscription|
      @subscriptions[subscription['id']] = subscription
    end
  end

  def set_back_url
    @back_url = list_subscriptions_path
  end

  def email_alert_api
    EmailAlertFrontend.services(:email_alert_api_with_no_caching)
  end
end
