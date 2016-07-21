require 'rails_helper'

RSpec.describe AutocompleteSearchController, type: :controller do
  include Helpers

  before(:each) do
    create(:bookmark, tag_list: 'rails1, rails2, rails3')
    create(:bookmark, tag_list: 'rails1, rails2, rails4')
    create(:bookmark, tag_list: 'rails2, rails5, rails6')
  end

  describe 'GET #tags' do
    context 'when no query parameter is given' do
      it 'returns an empty array' do
        get :tags, format: :json
        expect(response_body).to eq []
      end
    end

    context 'when a query parameter :q is given' do
      context 'when :q matches tags' do
        it 'returns the list of tags matching the query' do
          get :tags, format: :json, q: 'ra'
          expect(response_body).to be_a Array
          expect(response_body[0]).to eq 'rails2'
          expect(response_body[1]).to eq 'rails1'
          expect(response_body.count).to eq 5
        end
      end

      context 'when :q matches nothing' do
        it 'returns an empty array' do
          get :tags, format: :json, q: 'to'
          expect(response_body).to eq []
        end
      end

      context 'when :q is less than 2 characters' do
        it 'returns an empty array' do
          get :tags, format: :json, q: 'r'
          expect(response_body).to eq []
        end
      end
    end
  end

end
