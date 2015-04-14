class EmailAlertSignupPresenter

  delegate :title, :description, to: :content_item

  def initialize(content_item)
    @content_item = content_item
  end

private
  attr_reader :content_item

end
