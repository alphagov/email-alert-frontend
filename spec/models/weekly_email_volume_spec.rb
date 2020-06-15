RSpec.describe EmailVolume::WeeklyEmailVolume do
  include GdsApi::TestHelpers::ContentStore

  describe "#estimate" do
    let(:top_taxon) do
      { document_type: "taxon", base_path: "/top", links: { parent_taxons: [] } }.deep_stringify_keys
    end

    let(:second_taxon) do
      {
        document_type: "taxon", base_path: "/second", links: { parent_taxons: [{ base_path: "/top" }] }
      }.deep_stringify_keys
    end

    context "given the Coronavirus (COVID-19) taxon" do
      coronavirus_taxon = { document_type: "taxon", base_path: "/coronavirus-taxon", links: { parent_taxons: [] } }.deep_stringify_keys

      it "returns an EXTREME range" do
        expect(described_class.new(coronavirus_taxon).estimate).to eq EmailVolume::TaxonWeeklyEmailVolume::EXTREME
      end
    end

    context "given a top level taxon" do
      it "returns a HIGH range" do
        expect(described_class.new(top_taxon).estimate).to eq EmailVolume::TaxonWeeklyEmailVolume::HIGH
      end
    end

    context "given a 2nd level taxon" do
      before do
        stub_content_store_has_item(top_taxon["base_path"], top_taxon)
      end

      it "returns a MEDIUM range" do
        expect(described_class.new(second_taxon).estimate).to eq EmailVolume::TaxonWeeklyEmailVolume::MEDIUM
      end
    end

    context "given a 3rd level taxon" do
      let(:third_taxon) do
        {
          document_type: "taxon", base_path: "/third", links: { parent_taxons: [{ base_path: "/second" }] }
        }.deep_stringify_keys
      end

      before do
        stub_content_store_has_item(second_taxon["base_path"], second_taxon)
      end

      it "returns a LOW range" do
        expect(described_class.new(third_taxon).estimate).to eq EmailVolume::TaxonWeeklyEmailVolume::LOW
      end
    end

    context "given a top-level organisation" do
      let(:top_organisation) do
        { document_type: "organisation", base_path: "/ministry-of-funny-walks", links: { ordered_parent_organisations: [] } }.deep_stringify_keys
      end
      let(:second_organisation) do
        { document_type: "organisation", base_path: "/ministry-of-quite-funny-walks", links: { ordered_parent_organisations: [{ base_path: "/ministry-of-funny-walks" }] } }.deep_stringify_keys
      end
      let(:third_organisation) do
        { document_type: "organisation", base_path: "/ministry-of-normal-walks", links: { ordered_parent_organisations: [{ base_path: "/ministry-of-quite-funny-walks" }] } }.deep_stringify_keys
      end

      context "given a top level organisation" do
        it "returns a HIGH range" do
          expect(described_class.new(top_organisation).estimate).to eq EmailVolume::OrganisationWeeklyEmailVolume::HIGH
        end
      end
      context "given a 2nd level organisation" do
        before do
          stub_content_store_has_item(top_organisation["base_path"], top_organisation)
        end
        it "returns a MEDIUM range" do
          expect(described_class.new(second_organisation).estimate).to eq EmailVolume::OrganisationWeeklyEmailVolume::MEDIUM
        end
      end
      context "given a 3rd level organisation" do
        before do
          stub_content_store_has_item(second_organisation["base_path"], second_organisation)
        end
        it "returns a LOW range" do
          expect(described_class.new(third_organisation).estimate).to eq EmailVolume::OrganisationWeeklyEmailVolume::LOW
        end
      end
    end

    context "given a person" do
      it "returns nil as no estimate for a person" do
        person = { document_type: "person", base_path: "/people/big-boris" }.deep_stringify_keys
        expect(described_class.new(person).estimate).to be_nil
      end
    end
  end
end
