Rails.application.routes.draw do
  get '/*base_path' => 'email_alert_signups#new', as: :email_alert_signup, constraints: { base_path: %r|.*/email-signup|}
  post '/*base_path' => 'email_alert_signups#create', as: :email_alert_signups, constraints: { base_path: %r|.*/email-signup|}

  if Rails.env.test?
    get '/govdelivery-redirect', to: proc { [200, {}, ['']] }
  end
end
