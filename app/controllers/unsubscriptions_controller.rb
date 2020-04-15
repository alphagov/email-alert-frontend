class UnsubscriptionsController < ApplicationController
  before_action :set_attributes

  def confirm
    if subscription_ended?(@latest_subscription)
      render :confirm_already_unsubscribed
    elsif subscription_is_latest?
      render :confirm
    elsif old_subscription_has_same_frequency_as_latest?
      redirect_to_unsubscribe_latest
    else
      redirect_to_manage_subscriptions
    end
  end

  def confirmed
    unsubscribed = begin
                    api.unsubscribe(@id)
                   rescue GdsApi::HTTPNotFound
                    # The user has already unsubscribed.
                     nil
                  end

    if @authenticated_for_subscription
      message = if @title
                  "You have been unsubscribed from ‘#{@title}’"
                else
                  "You have been unsubscribed"
                end
      description = "It can take up to an hour for this change to take effect."

      if unsubscribed
        flash[:success] = {
          message: message,
          description: description,
        }
      end

      redirect_to list_subscriptions_path
    end
  end

private

  def set_attributes
    @id = params.require(:id)
    @original_subscription = api.get_subscription(@id)
    @latest_subscription = api.get_latest_matching_subscription(@id)
    @title = @latest_subscription.dig("subscription", "subscriber_list", "title").presence
    @authenticated_for_subscription = check_authenticated(@latest_subscription)
  end

  def subscription_is_latest?
    id(@original_subscription) == id(@latest_subscription)
  end

  def old_subscription_has_same_frequency_as_latest?
    frequency(@latest_subscription) == frequency(@original_subscription)
  end

  def subscription_ended?(subscription)
    subscription.dig("subscription", "ended_at").present?
  end

  def id(subscription)
    subscription.dig("subscription", "id")
  end

  def frequency(subscription)
    subscription.dig("subscription", "frequency")
  end

  def check_authenticated(subscription)
    if authenticated?
      subscriber_id = subscription.dig("subscription", "subscriber", "id")
      subscriber_id == authenticated_subscriber_id
    else
      false
    end
  end

  def api
    EmailAlertFrontend.services(:email_alert_api)
  end

  def redirect_to_unsubscribe_latest
    redirect_to "/email/unsubscribe/#{id(@latest_subscription)}"
  end

  def redirect_to_manage_subscriptions
    # Whilst it would be nice to direct to 'https://www.gov.uk/email/manage' instead
    # (and treat the user as authenticated), this would open a security hole whereby
    # if user A forwards an email to user B, then subsequently changes their
    # frequency, user B could click on the old unsubscribe link and view user A's
    # subscriptions. So DON'T change this line:
    redirect_to "/email/authenticate"
  end
end
