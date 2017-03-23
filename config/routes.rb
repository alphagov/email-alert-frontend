Rails.application.routes.draw do
  get '/*base_path' => 'email_alert_signups#new', as: :email_alert_signup, constraints: { base_path: %r|.*/email-signup|}
  post '/*base_path' => 'email_alert_signups#create', as: :email_alert_signups, constraints: { base_path: %r|.*/email-signup|}

  get '/email-signup' => 'taxonomy_signups#new', as: :new_taxonomy_signup
  get '/email-signup/confirm' => 'taxonomy_signups#confirm', as: :confirm_taxonomy_signup
  post '/email-signup' => 'taxonomy_signups#create'

  if Rails.env.test?
    get '/govdelivery-redirect', to: proc { [200, {}, ['']] }
  end
end
