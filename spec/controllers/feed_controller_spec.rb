require 'rails_helper'

RSpec.describe FeedController, type: :controller do

  describe "GET #index" do
    context 'when the user is not signed_in' do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when the user is signed_in' do

      let(:userA) { create(:user) }
      let(:userB) { create(:user) }



      before(:each) { sign_in_user(userA) }

      context 'when the user has bookmarks' do
        let!(:userA_bookmarks) { create_list(:bookmark, 3, user: userA) }

        # With no parameters
        context 'without parameter' do
          context 'when userA does not follow userB' do
            let!(:userB_public_bookmarks) { create_list(:bookmark, 2, user: userB) }
            let!(:userB_private_bookmarks) { create_list(:bookmark_visible_to_only_me, 3, user: userB) }

            it "assigns userA's bookmarks as @bookmarks" do
              visible_bookmarks = userA_bookmarks
              get :index
              expect(assigns(:bookmarks)).to match_array(visible_bookmarks)
            end
          end

          context 'when userA follows userB' do
            before(:each) do
              userA.follow(userB)
            end

            let!(:userB_public_bookmarks) { create_list(:bookmark, 2, user: userB) }
            let!(:userB_private_bookmarks) { create_list(:bookmark_visible_to_only_me, 3, user: userB) }

            it "assigns userA's and userB's public bookmarks as @bookmarks" do
              visible_bookmarks = userA_bookmarks + userB_public_bookmarks
              get :index
              expect(assigns(:bookmarks)).to match_array(visible_bookmarks)
            end
          end

          it "tracks an ahoy event" do
            expect{
              get :index
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'feed-index'
            expect(event.properties).to be_nil
          end
        end

        # Filter everyone
        context 'with filter parameter' do
          context 'when filter == everyone' do
            let!(:userB_public_bookmarks) { create_list(:bookmark, 2, user: userB) }
            let!(:userB_private_bookmarks) { create_list(:bookmark_visible_to_only_me, 3, user: userB) }

            it "assigns every public bookmarks as @bookmarks" do
              visible_bookmarks = userA_bookmarks + userB_public_bookmarks
              get :index, filter: 'everyone'
              expect(assigns(:bookmarks)).to match_array(visible_bookmarks)
            end
          end
        end

        # Search parameter
        context 'with a q parameter' do
          before(:each) do
            @userA_match_public_bookmark = create(:bookmark_visible_to_everyone, user: userA, title: "I love Ruby on Rails", description: 'userA_match_public_bookmark')
            @userA_match_private_bookmark = create(:bookmark_visible_to_only_me, user: userA, title: "I love Ruby on Rails", description: 'userA_match_private_bookmark')
            @userB_match_public_bookmark = create(:bookmark_visible_to_everyone, user: userB, title: "I love Ruby on Rails", description: 'userB_match_public_bookmark')
            @userB_match_private_bookmark = create(:bookmark_visible_to_only_me, user: userB, title: "I love Ruby on Rails", description: 'userB_match_private_bookmark')
            @userA_unmatch_public_bookmark = create(:bookmark_visible_to_everyone, user: userA, title: "I love cakes", description: 'userA_unmatch_public_bookmark')
            @userC_match_public_bookmark = create(:bookmark_visible_to_everyone, title: "I love Ruby on Rails", description: 'userC_match_public_bookmark')
          end

          it "assigns visible bookmarks matching the search results" do
            # See only his own bookmarks
            get :index, q: 'rails'
            expect(assigns(:bookmarks)).to match_array([@userA_match_public_bookmark, @userA_match_private_bookmark])

            # When userA follows userB, he also sees userB's bookmarks
            userA.follow(userB)
            get :index, q: 'rails'
            expect(assigns(:bookmarks).reload).to match_array([@userA_match_public_bookmark, @userA_match_private_bookmark, @userB_match_public_bookmark])

            # When userA search with filter='everyone', he sees every bookmarks
            get :index, q: 'rails', filter: 'everyone'
            expect(assigns(:bookmarks).reload).to match_array([@userA_match_public_bookmark, @userA_match_private_bookmark, @userB_match_public_bookmark, @userC_match_public_bookmark])
          end

          context 'when bookmarks are matching' do
            it "displays a notice and offer to search in all wundermarks" do
              get :index, q: 'rails'
              expect(flash[:notice]).to eq I18n.t("feed.index.search.search_all_wundermarks", count: 2, search_all_url: feed_path(q: 'rails', filter: 'everyone'))
            end

            it "tracks an ahoy event" do
              expect{
                get :index, q: 'rails'
              }.to change(Ahoy::Event, :count).by(1)
              event = Ahoy::Event.last
              expect(event.name).to eq 'feed-search'
              expect(event.properties).to eq({"q" => 'rails', "results_count" => 2})
            end
          end

          context 'when no bookmark is matching' do
            it "displays a notice and offer to make a new search" do
              get :index, q: 'abcd'
              expect(flash[:notice]).to eq I18n.t("feed.index.search.nothing_found_html")
            end

            it "tracks an ahoy event" do
              expect{
                get :index, q: 'abcd'
              }.to change(Ahoy::Event, :count).by(1)
              event = Ahoy::Event.last
              expect(event.name).to eq 'feed-search'
              expect(event.properties).to eq({"q" => 'abcd', "results_count" => 0})
            end
          end
        end

        # Pagination

        context 'when there are more than 25 bookmarks' do
          it 'paginates the bookmarks list' do
            bookmarks = create_list(:bookmark, 27, user: userA)
            get :index
            expect(assigns(:bookmarks).to_a.size).to eq 25
            get :index, page: 2
            expect(assigns(:bookmarks).to_a.size).to eq 5
          end

          it 'paginates the search results' do
            bookmarks = create_list(:bookmark, 28, user: userA, title: 'ATRFGE')
            get :index, q: 'ATRFGE'
            expect(assigns(:bookmarks).to_a.size).to eq 25
            get :index, q: 'ATRFGE', page: '2'
            expect(assigns(:bookmarks).to_a.size).to eq 3
          end
        end

        # Bookmark likes

        context 'when current user liked a bookmark' do
          let!(:userB_bookmarks) { create_list(:bookmark, 3, user: userB) }

          it "sets to @bookmarks which bookmark the current user liked" do
            liked_bookmarked = userB_bookmarks[1]
            BookmarkLike.create(bookmark_id: liked_bookmarked.id, user_id: userA.id)

            get :index

            bookmarks = assigns(:bookmarks)
            bookmarks.each do |b|
              expect(b.liked?).to eq(b.id == liked_bookmarked.id)
            end
          end
        end
      end


      # No bookmark redirects to getting started

      context 'when the bookmark list is empty and user has no bookmark' do
        it "redirects to getting started page" do
          get :index
          expect(response).to redirect_to getting_started_path(source: "feed-no_bookmarks")
        end
      end
    end
  end

end
