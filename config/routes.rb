Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::Redis,
  )

  root to: "development#index"

  match "*" => "maintenance#show", via: %i[get post] if Rails.application.config.maintenance_mode

  get "/*base_path" => "email_alert_signups#new", as: :email_alert_signup, constraints: { base_path: %r{.*/email-signup} }
  post "/*base_path" => "email_alert_signups#create", as: :email_alert_signups, constraints: { base_path: %r{.*/email-signup} }

  get "/email-signup" => "content_item_signups#new", as: :new_content_item_signup
  get "/email-signup/confirm" => "content_item_signups#confirm", as: :confirm_content_item_signup
  post "/email-signup" => "content_item_signups#create"

  scope "/email" do
    get "/unsubscribe/:id" => "unsubscriptions#confirm", as: :confirm_unsubscribe
    post "/unsubscribe/one-click/:id" => "unsubscriptions#one_click", as: :one_click
    post "/unsubscribe/:id" => "unsubscriptions#confirmed", as: :unsubscribe

    scope "/manage" do
      get "/" => "subscriptions_management#index", as: :list_subscriptions
      get "/frequency/:id" => "subscriptions_management#update_frequency", as: :update_frequency
      post "/frequency/:id/change" => "subscriptions_management#change_frequency", as: :change_frequency
      get "/address" => "subscriptions_management#update_address", as: :update_address
      post "/address/change" => "subscriptions_management#change_address", as: :change_address
      get "/unsubscribe-all" => "subscriptions_management#confirm_unsubscribe_all", as: :confirm_unsubscribe_all
      post "/unsubscribe-all" => "subscriptions_management#confirmed_unsubscribe_all", as: :unsubscribe_all

      get "/authenticate" => "subscriber_authentication#sign_in", as: :sign_in
      post "/authenticate" => "subscriber_authentication#verify", as: :verify_subscriber
      get "/authenticate/process" => "subscriber_authentication#process_sign_in_token", as: :process_sign_in_token
      get "/authenticate/account" => "subscriber_authentication#process_govuk_account", as: :process_govuk_account
      post "/authenticate/account" => "subscriber_authentication#process_govuk_account"
    end

    scope "/subscriptions" do
      get "/new" => "subscriptions#new", as: :new_subscription
      post "/frequency" => "subscriptions#frequency", as: :subscription_frequency
      post "/verify" => "subscriptions#verify", as: :verify_subscription
      post "/verify/account" => "subscriptions#verify_account", as: :verify_subscription_account
      get "/authenticate" => "subscription_authentication#authenticate", as: :confirm_subscription
      post "/single-page/new" => "govuk_account_signups#create"
      get "/single-page/new" => "govuk_account_signups#show", as: :new_govuk_account_signup
      post "/single-page/new-session" => "govuk_account_signups#edit", as: :govuk_account_signups_new_session
      scope "/account" do
        get "/confirm" => "account_subscriptions#confirm", as: :confirm_account_subscription
        post "/" => "account_subscriptions#create"
      end
    end

    # DEPRECATED: legacy route in emails from GOV.UK
    get "/authenticate", to: redirect("/email/manage/authenticate")
  end
end
