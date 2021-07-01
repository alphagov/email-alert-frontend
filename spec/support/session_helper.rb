module SessionHelper
  def session_for(subscriber_id, linked_to_govuk_account: false)
    {
      "authentication": {
        "subscriber_id": subscriber_id,
        "linked_to_govuk_account": linked_to_govuk_account,
      },
    }.with_indifferent_access
  end
end
