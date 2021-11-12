module AccountHelper
  def govuk_account_auth_enabled?
    ENV["FEATURE_FLAG_GOVUK_ACCOUNT"] != "disabled"
  end
end
