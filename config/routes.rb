Rails.application.routes.draw do
  unless Rails.env.production?
    mount GovukPublishingComponents::Engine, at: "/component-guide" if defined?(GovukPublishingComponents)
  end

  get '/*base_path' => 'email_alert_signups#new', as: :email_alert_signup, constraints: { base_path: %r|.*/email-signup| }
  post '/*base_path' => 'email_alert_signups#create', as: :email_alert_signups, constraints: { base_path: %r|.*/email-signup| }

  get '/email-signup' => 'taxonomy_signups#new', as: :new_taxonomy_signup
  get '/email-signup/confirm' => 'taxonomy_signups#confirm', as: :confirm_taxonomy_signup
  post '/email-signup' => 'taxonomy_signups#create'

  get '/email/unsubscribe/:uuid' => 'unsubscriptions#confirm', as: :confirm_unsubscribe
  post '/email/unsubscribe/:uuid' => 'unsubscriptions#confirmed', as: :unsubscribe

  scope '/email' do
    resources :subscriptions, only: %i[create new]
    get '/subscriptions/complete' => 'subscriptions#show', as: :subscription
  end

  if Rails.env.test?
    get '/govdelivery-redirect', to: proc { [200, {}, ['']] }
  end
end
