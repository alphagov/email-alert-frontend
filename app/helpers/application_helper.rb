module ApplicationHelper
  def live_content_item?(content_item)
    content_item["phase"] == "live"
  end
end
