require 'rails_helper'

RSpec.describe TaxonomySignupsController do
  include GdsApi::TestHelpers::ContentStore

  shared_examples 'handles bad input data correctly' do
    it 'redirects to root if topic param is missing' do
      make_request(bad_param: '/education/some-rando-item')

      expect(response.status).to eq 302
      expect(response.location).to eq 'http://test.host/'
    end

    it "redirects to root if topic param isn't a valid path" do
      get :new, topic: '/with unencoded spaces'

      expect(response.status).to eq 302
      expect(response.location).to eq 'http://test.host/'
    end

    it "redirects to root if topic param isn't interpreted as a string" do
      get :new, topic: ['/a']

      expect(response.status).to eq 302
      expect(response.location).to eq 'http://test.host/'
    end

    it 'errors if no taxon found' do
      content_store_does_not_have_item('/education/some-rando-item')
      make_request(topic: '/education/some-rando-item')

      expect(response.status).to eq 404
    end

    it 'redirects to root unless the content item is a taxon' do
      content_store_has_item('/cma-cases', document_type: 'finder')
      make_request(topic: '/cma-cases')

      expect(response.status).to eq 302
      expect(response.location).to eq 'http://test.host/'
    end
  end

  describe "#new" do
    def make_request(params)
      get :new, params
    end

    it_behaves_like 'handles bad input data correctly'
  end

  describe "#confirm" do
    def make_request(params)
      get :confirm, params
    end

    it_behaves_like 'handles bad input data correctly'
  end

  describe "#create" do
    def make_request(params)
      post :create, params
    end

    it_behaves_like 'handles bad input data correctly'
  end
end
