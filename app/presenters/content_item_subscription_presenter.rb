class ContentItemSubscriptionPresenter
  def initialize(content_item)
    @content_item = content_item
  end

  def title
    if content_item["content_id"] == "c4cd0e8a-3ae1-4385-8936-1cfafe5031fb"
      "Coronavirus (COVID-19)"
    else
      content_item["title"]
    end
  end

  def description
    description = content_item["description"]

    return if description.blank?

    return "This will include: #{description}" if is_taxon?

    description
  end

  def child_taxons
    return unless is_taxon?

    content_item["links"]
      .fetch("child_taxons", [])
      .reject { |taxon| taxon["phase"] == "alpha" }
  end

private

  attr_accessor :content_item

  def is_taxon?
    content_item["document_type"] == "taxon"
  end
end
