Rails.application.routes.draw do

  get '/*base_path' => 'email_alert_signups#new', as: :email_alert_signup, constraints: { base_path: %r|.*/email-signup|}

end
