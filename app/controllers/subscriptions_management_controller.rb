class SubscriptionsManagementController < ApplicationController
  include Slimmer::Headers
  include Slimmer::Template
  before_action :handle_one_login_hint, only: [:index]
  before_action :require_authentication
  before_action :get_subscription_details
  before_action :set_back_url
  before_action :use_govuk_account_layout?

  def index; end

  def update_frequency
    @subscription_id = params.require(:id)
    return error_not_found unless @subscriptions[@subscription_id]

    @current_frequency = @subscriptions[@subscription_id]["frequency"]
  end

  def change_frequency
    id = params.require(:id)
    return error_not_found unless @subscriptions[id]

    new_frequency = params.require(:new_frequency)

    GdsApi.email_alert_api.change_subscription(id:, frequency: new_frequency)

    subscription = @subscriptions[id]

    subscription_type = is_single_page_subscription?(subscription) ? "page" : "topic"

    subscription_title = subscription["subscriber_list"]["title"]

    frequency_text = if new_frequency == "immediately"
                       I18n.t!("frequencies.#{subscription_type}.immediately").downcase
                     else
                       new_frequency
                     end

    flash[:success] = {
      message: t("subscriptions_management.change_frequency.success", subscription_title:, frequency: frequency_text),
      message_en: t("subscriptions_management.change_frequency.success", subscription_title:, frequency: frequency_text, locale: :en),
    }

    redirect_to list_subscriptions_path
  end

  def update_address
    head :not_found and return if authenticated_via_account?

    @address = @subscriber["address"]
  end

  def change_address
    head :not_found and return if authenticated_via_account?

    @address = @subscriber["address"]

    if params[:new_address].blank?
      flash.now[:error] = t("subscriptions_management.update_address.missing_email")
      return render :update_address
    end

    new_address = params.require(:new_address)

    GdsApi.email_alert_api.change_subscriber(
      id: authenticated_subscriber_id,
      new_address:,
    )
    flash[:success] = {
      message: t("subscriptions_management.update_address.success", address: new_address),
      message_en: t("subscriptions_management.update_address.success", address: new_address, locale: :en),
    }

    redirect_to list_subscriptions_path
  rescue GdsApi::HTTPUnprocessableEntity
    @new_address = new_address
    flash.now[:error] = t("subscriptions_management.update_address.invalid_email")
    render :update_address
  end

  def confirm_unsubscribe_all; end

  def confirmed_unsubscribe_all
    begin
      GdsApi.email_alert_api.unsubscribe_subscriber(authenticated_subscriber_id)
      flash[:success] = {
        message: t("subscriptions_management.confirmed_unsubscribe_all.success_message"),
        message_en: t("subscriptions_management.confirmed_unsubscribe_all.success_message", locale: :en),
        description: t("subscriptions_management.confirmed_unsubscribe_all.success_description"),
      }
    rescue GdsApi::HTTPNotFound
      # The user has already unsubscribed.
      nil
    end
    redirect_to list_subscriptions_path
  end

  def use_govuk_account_layout?
    @use_govuk_account_layout ||=
      if authenticated_via_account?
        set_slimmer_headers(template: "gem_layout_account_manager", remove_search: true, show_accounts: "signed-in")
        true
      end
  end

private

  def handle_one_login_hint
    return unless params[:from] == "your-services" && !authenticated?

    redirect_with_analytics GdsApi.account_api.get_sign_in_url(redirect_path: list_subscriptions_path)["auth_uri"]
  end

  def get_subscription_details
    subscription_details = GdsApi.email_alert_api.get_subscriptions(
      id: authenticated_subscriber_id,
    )

    @subscriber = subscription_details["subscriber"]
    @subscriptions = {}

    subscription_details["subscriptions"].each do |subscription|
      @subscriptions[subscription["id"]] = subscription
    end
  end

  def set_back_url
    @back_url = list_subscriptions_path
  end

  def is_single_page_subscription?(subscription)
    subscription.dig("subscriber_list", "content_id").present?
  end
  helper_method :is_single_page_subscription?
end
