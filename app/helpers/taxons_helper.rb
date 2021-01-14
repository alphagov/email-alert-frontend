module TaxonsHelper
  def is_taxon_with_children?(content_item)
    content_item["document_type"] == "taxon" &&
      taxon_children(content_item).any?
  end

  def taxon_children(content_item)
    content_item["links"]
      .fetch("child_taxons", [])
      .reject { |taxon| taxon["phase"] == "alpha" }
  end
end
