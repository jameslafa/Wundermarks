require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }
    let!(:bookmarks) { create_list(:bookmark, 3, user: user) }

    context 'without query parameter' do
      it "assigns all bookmarks as @bookmarks" do
        get :index
        expect(assigns(:bookmarks)).to match_array(bookmarks)
      end

      it "sorts the bookmarks list by reverse chronology" do
        ordered_list = bookmarks.sort { |x,y| y.created_at <=> x.created_at }
        get :index
        expect(assigns(:bookmarks)).to eq(ordered_list)
      end
    end

    context 'with a query parameter' do
      before(:each) do
        @searched_bookmark = bookmarks.second
        @searched_bookmark.update_attributes({title: "I love Ruby on Rails"})
      end

      it "assigns all bookmarks matching the search results" do
        get :index, q: 'rails'
        expect(assigns(:bookmarks)).to eq([@searched_bookmark])
      end
    end
  end
end
