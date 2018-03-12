Rails.application.routes.draw do
  mount GovukPublishingComponents::Engine, at: "/component-guide" if defined?(GovukPublishingComponents)

  get '/*base_path' => 'email_alert_signups#new', as: :email_alert_signup, constraints: { base_path: %r|.*/email-signup| }
  post '/*base_path' => 'email_alert_signups#create', as: :email_alert_signups, constraints: { base_path: %r|.*/email-signup| }

  get '/email-signup' => 'taxonomy_signups#new', as: :new_taxonomy_signup
  get '/email-signup/confirm' => 'taxonomy_signups#confirm', as: :confirm_taxonomy_signup
  post '/email-signup' => 'taxonomy_signups#create'

  scope '/email' do
    get '/unsubscribe/:uuid' => 'unsubscriptions#confirm', as: :confirm_unsubscribe
    post '/unsubscribe/:uuid' => 'unsubscriptions#confirmed', as: :unsubscribe

    scope '/subscriptions' do
      get '/new' => 'subscriptions#new', as: :new_subscription
      post '/frequency' => 'subscriptions#frequency', as: :subscription_frequency
      post '/create' => 'subscriptions#create', as: :create_subscription
      get '/complete' => 'subscriptions#complete', as: :subscription
    end
  end

  if Rails.env.test?
    get '/govdelivery-redirect', to: proc { [200, {}, ['']] }
  end
end
