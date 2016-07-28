require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  include Helpers

  describe "GET #index" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    let!(:bookmarks) { create_list(:bookmark, 3, user: user) }
    let!(:other_user_bookmarks) { create_list(:bookmark, 2, user: other_user) }
    let!(:other_user_private_bookmarks) { create_list(:bookmark_visible_to_only_me, 3, user: other_user) }

    context 'when no user is signed_in' do
      context 'without query parameter' do
        let(:visible_bookmarks) { [bookmarks, other_user_bookmarks].flatten }

        it "assigns only visible bookmarks as @bookmarks" do
          get :index
          expect(assigns(:bookmarks)).to match_array(visible_bookmarks)
        end

        it "sorts the bookmarks list by reverse chronology" do
          ordered_list = visible_bookmarks.sort { |x,y| y.created_at <=> x.created_at }
          get :index
          expect(assigns(:bookmarks)).to eq(ordered_list)
        end
      end

      context 'with a query parameter' do
        before(:each) do
          @searched_bookmark = bookmarks.second
          @searched_bookmark.update_attributes({title: "I love Ruby on Rails"})
          other_user_private_bookmarks.first.update_attributes({title: "I love Ruby on Rails"})
        end

        it "assigns all visible bookmarks matching the search results" do
          get :index, q: 'rails'
          expect(assigns(:bookmarks)).to eq([@searched_bookmark])
        end
      end
    end

    context 'when the user is signed_in' do
      before(:each) { sign_in_user(other_user) }

      context 'without query parameter' do
        let(:visible_bookmarks) { [bookmarks, other_user_bookmarks, other_user_private_bookmarks].flatten }

        it "assigns only visible bookmarks as @bookmarks" do
          get :index
          expect(assigns(:bookmarks)).to match_array(visible_bookmarks)
        end
      end

      context 'with a query parameter' do
        before(:each) do
          @searched_bookmark = bookmarks.second
          @searched_bookmark.update_attributes({title: "I love Ruby on Rails"})
          @private_searched_bookmark = other_user_private_bookmarks.first
          @private_searched_bookmark.update_attributes({title: "I love Ruby on Rails"})
        end

        it "assigns all visible bookmarks matching the search results" do
          get :index, q: 'rails'
          expect(assigns(:bookmarks)).to match_array([@private_searched_bookmark, @searched_bookmark])
        end
      end
    end
  end
end
