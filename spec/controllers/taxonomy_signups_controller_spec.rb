require 'rails_helper'

RSpec.describe TaxonomySignupsController do
  include GdsApi::TestHelpers::ContentStore

  describe "GET new" do
    it 'redirects to root unless valid query param provided' do
      get :new, bad_param: '/education/some-rando-item'

      expect(response.status).to eq 302
      expect(response.location).to eq 'http://test.host/'
    end

    it 'errors if no taxon found' do
      content_store_does_not_have_item('/education/some-rando-item')
      get :new, topic: '/education/some-rando-item'

      expect(response.status).to eq 404
    end
  end
end
