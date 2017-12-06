require 'rails_helper'

RSpec.describe WeeklyEmailVolume do
  include GdsApi::TestHelpers::ContentStore

  describe "#estimate" do
    let(:top_taxon) do
      { base_path: '/top', links: { parent_taxons: [] } }.deep_stringify_keys
    end

    let(:second_taxon) do
      {
        base_path: '/second', links: { parent_taxons: [{ base_path: '/top' }] }
      }.deep_stringify_keys
    end

    context 'given a top level taxon' do
      it 'returns a HIGH range' do
        expect(WeeklyEmailVolume.new(top_taxon).estimate).to eq WeeklyEmailVolume::HIGH
      end
    end

    context 'given a 2nd level taxon' do
      before do
        content_store_has_item(top_taxon['base_path'], top_taxon)
      end

      it 'returns a MEDIUM range' do
        expect(WeeklyEmailVolume.new(second_taxon).estimate).to eq WeeklyEmailVolume::MEDIUM
      end
    end

    context 'given a 3rd level taxon' do
      let(:third_taxon) do
        {
          base_path: '/third', links: { parent_taxons: [{ base_path: '/second' }] }
        }.deep_stringify_keys
      end

      before do
        content_store_has_item(second_taxon['base_path'], second_taxon)
      end

      it 'returns a LOW range' do
        expect(WeeklyEmailVolume.new(third_taxon).estimate).to eq WeeklyEmailVolume::LOW
      end
    end
  end
end
