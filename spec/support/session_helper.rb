module SessionHelper
  def session_for(subscriber_id)
    {
      "authentication": {
        "subscriber_id": subscriber_id,
      },
    }.with_indifferent_access
  end
end
