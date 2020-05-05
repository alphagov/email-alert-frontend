RSpec.describe ContentItemSubscriptionPresenter do
  describe "#description" do
    let(:fake_taxon) { { "document_type" => "taxon", "description" => "description of foo-id" } }
    let(:fake_organisation) { { "document_type" => "organisation", "description" => "description of magic-id" } }

    context "given a taxon" do
      it "Prepends 'this will include:'" do
        presenter = described_class.new(fake_taxon)
        expect(presenter.description).to eq "This will include: description of foo-id"
      end

      it "returns nothing when there is no description" do
        fake_taxon_without_description = { "document_type" => "taxon", "description" => nil }
        presenter = described_class.new(fake_taxon_without_description)
        expect(presenter.description).to be_nil
      end
    end

    context "given an organisation" do
      it "returns the content item description" do
        presenter = described_class.new(fake_organisation)
        expect(presenter.description).to eq "description of magic-id"
      end
    end
  end
end
