require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  include ActiveJob::TestHelper
  include ActionView::Helpers::UrlHelper

  let(:valid_attributes) { attributes_for(:bookmark_with_tags) }
  let(:invalid_attributes) { attributes_for(:bookmark_with_tags, title: '') }

  context "without a signed_in user" do
    let(:bookmark) { create(:bookmark) }

    describe "GET #index" do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show" do
      context 'without redirect=1' do
        it "renders template :show" do
          get :show, {id: bookmark.id}
          expect(response).to render_template :show
        end

        it 'tracks an ahoy event' do
          expect{
            get :show, {id: bookmark.id}
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-show'
          expect(event.properties).to eq({"id" => bookmark.id})
        end
      end

      context 'with redirect=1' do
        it 'redirects to the bookmark url' do
          get :show, {id: bookmark.id, redirect: "1"}
          expect(response).to redirect_to bookmark.url
        end
      end

      context 'when a utm_medium is defined' do
        it 'tracks the click and associate it to the specific social media' do
          expect{
            get :show, {id: bookmark.id, redirect: "1", utm_medium: 'facebook'}
          }.to change(BookmarkTracking, :count).by(1)
          last_bookmark_tracking = BookmarkTracking.last
          expect(last_bookmark_tracking.bookmark).to eq bookmark
          expect(last_bookmark_tracking.source).to eq "facebook"
        end
      end

      context 'when no utm_medium is defined' do
        it 'tracks the click and associate it to wundermarks' do
          expect{
            get :show, {id: bookmark.id}
          }.to change(BookmarkTracking, :count).by(1)
          last_bookmark_tracking = BookmarkTracking.last
          expect(last_bookmark_tracking.bookmark).to eq bookmark
          expect(last_bookmark_tracking.source).to eq "wundermarks"
        end
      end

      context 'when privacy is not "everyone"' do
        context 'with a bookmark visile to only me' do
          let(:bookmark) { create(:bookmark_visible_to_only_me) }

          context 'with a html format' do
            it 'redirects to bookmarks_path with an alert' do
              get :show, id: bookmark.id
              expect(response).to redirect_to bookmarks_path
              expect(flash[:alert]).to eq I18n.t("pundit.bookmark_policy.show?")
            end
          end

          context 'with a json format' do
            it 'responds with a 403' do
              get :show, id: bookmark.id, format: :json
              expect(response.status).to eq 403
              expect(response_body).to eq({"error" => I18n.t("pundit.bookmark_policy.show?")})
            end
          end
        end
      end
    end

    describe "GET #new" do
      it "redirects to new_user_session_path" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #edit" do
      it "redirects to new_user_session_path" do
        get :edit, {id: bookmark.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST #create" do
      it "redirects to new_user_session_path" do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PUT #update" do
      it "redirects to new_user_session_path" do
        put :update, {id: bookmark.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "DELETE #destroy" do
      it "redirects to new_user_session_path" do
        delete :destroy, {id: bookmark.id}
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context "with a signed_in user " do
    before(:each) { sign_in_user }

    describe "GET #index" do
      context "when the current user already has bookmarks" do
        let(:other_user) { create(:user) }

        let!(:other_user_bookmarks) { create_list(:bookmark, 3, user: other_user) }
        let!(:current_user_bookmarks) { create_list(:bookmark, 3, user: subject.current_user) }

        it "assigns all bookmarks belonging to current_user as @bookmarks" do
          get :index
          expect(assigns(:bookmarks)).to match_array(current_user_bookmarks)
        end

        it "sorts the bookmarks list by reverse chronology" do
          ordered_list = current_user_bookmarks.sort { |x,y| y.created_at <=> x.created_at }
          get :index
          expect(assigns(:bookmarks)).to eq(ordered_list)
        end

        it "tracks an ahoy event" do
          expect{
            get :index
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-index'
          expect(event.properties).to be_nil
        end

        context 'when a query parameter is defined' do
          before(:each) do
            @searched_bookmark = current_user_bookmarks.second
            @searched_bookmark.update_attributes({title: "I love Ruby on Rails"})
          end

          it "assigns all bookmarks matching the search results belonging to the current user" do
            get :index, q: 'rails'
            expect(assigns(:bookmarks)).to eq([@searched_bookmark])
          end

          it "displays a notice and offer to search in all wundermarks" do
            get :index, q: 'rails'
            expect(flash[:notice]).to eq I18n.t("bookmarks.index.search.search_all_wundermarks", count: 1, search_friends_url: feed_path(q: 'rails'), search_all_url: feed_path(q: 'rails', filter: 'everyone'))
          end

          it "tracks an ahoy event" do
            expect{
              get :index, q: 'rails'
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'bookmarks-search'
            expect(event.properties).to eq({"q" => 'rails', "results_count" => 1})
          end
        end

        context 'when a post_import parameter is defined' do
          let!(:delicious_bookmarks) { create_list(:bookmark, 3, user: subject.current_user, source: 'delicious') }

          it "assigns all bookmarks imported by the service" do
            get :index, post_import: 'delicious'
            expect(assigns(:bookmarks)).to match_array(delicious_bookmarks)
          end

          it "tracks an ahoy event" do
            expect{
              get :index, post_import: 'delicious'
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'bookmarks-post_import'
            expect(event.properties).to eq({"source" => 'delicious', "count" => 3})
          end
        end

        context 'when the user has more than 25 bookmarks' do
          it 'paginates the bookmarks list' do
            bookmarks = current_user_bookmarks + create_list(:bookmark, 25, user: subject.current_user)
            get :index
            expect(assigns(:bookmarks)).to match_array(bookmarks.last(25))
            get :index, page: 2
            expect(assigns(:bookmarks)).to match_array(bookmarks.first(3))
          end

          it 'paginates the search results' do
            bookmarks = create_list(:bookmark, 28, user: subject.current_user, title: 'ATRFGE')
            get :index, q: 'ATRFGE'
            expect(assigns(:bookmarks).to_a.size).to eq 25
            get :index, q: 'ATRFGE', page: '2'
            expect(assigns(:bookmarks).to_a.size).to eq 3
          end

          it 'paginates the delicious imports' do
            bookmarks = create_list(:bookmark, 28, user: subject.current_user, source: 'delicious')
            get :index, post_import: 'delicious'
            expect(assigns(:bookmarks)).to match_array(bookmarks.last(25))
            get :index, post_import: 'delicious', page: '2'
            expect(assigns(:bookmarks)).to match_array(bookmarks.first(3))
          end
        end
      end

      context "when the current user has no bookmark" do
        it "redirects to getting_started page" do
          get :index
          expect(response).to redirect_to getting_started_path(source: "bookmarks-no_bookmarks")
        end
      end

    end

    describe "GET #show" do
      let(:bookmark) { create(:bookmark) }

      it "assigns the requested bookmark as @bookmark and render :show" do
        get :show, {:id => bookmark.id}
        expect(assigns(:bookmark)).to eq(bookmark)
        expect(response).to render_template :show
      end

      it 'tracks an ahoy event' do
        expect{
          get :show, {id: bookmark.id}
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'bookmarks-show'
        expect(event.properties).to eq({"id" => bookmark.id})
      end

      context 'when no utm_medium is defined' do
        context 'when the current_user is the bookmark owner' do
          let(:bookmark) { create(:bookmark, user: subject.current_user) }

          it 'does not tracks the click' do
            expect{
              get :show, {id: bookmark.id}
            }.not_to change(BookmarkTracking, :count)
          end
        end

        context 'when the current_user is NOT the bookmark owner' do
          let(:bookmark) { create(:bookmark) }
          it 'tracks the click and associate it to wundermarks' do
            expect{
              get :show, {id: bookmark.id}
            }.to change(BookmarkTracking, :count).by(1)
            last_bookmark_tracking = BookmarkTracking.last
            expect(last_bookmark_tracking.bookmark).to eq bookmark
            expect(last_bookmark_tracking.source).to eq "wundermarks"
          end
        end
      end

      context 'when privacy is not "everyone"' do
        context 'with a bookmark visile to only me' do
          let(:bookmark) { create(:bookmark_visible_to_only_me) }

          context 'with a html format' do
            it 'redirects to bookmarks_path with an alert' do
              get :show, id: bookmark.id
              expect(response).to redirect_to bookmarks_path
              expect(flash[:alert]).to eq I18n.t("pundit.bookmark_policy.show?")
            end
          end

          context 'with a json format' do
            it 'responds with a 403' do
              get :show, id: bookmark.id, format: :json
              expect(response.status).to eq 403
              expect(response_body).to eq({"error" => I18n.t("pundit.bookmark_policy.show?")})
            end
          end
        end
      end
    end

    describe "GET #new" do
      context "when the user bookmarks bookmarklet_tool_path" do
        it "redirects to bookmarklet_successfully_installed_path with the bookmark version" do
          get :new, url: bookmarklet_tool_url, v: "1469795299"
          expect(response).to redirect_to bookmarklet_successfully_installed_path(v: "1469795299")

          get :new, url: bookmarklet_tool_url(host: "www.#{Rails.application.routes.default_url_options[:host]}"), v: "1469795299"
          expect(response).to redirect_to bookmarklet_successfully_installed_path(v: "1469795299")
        end
      end

      context "when the user bookmarks another url" do
        it "assigns a new bookmark as @bookmark" do
          get :new
          expect(assigns(:bookmark)).to be_a_new(Bookmark)
        end

        it "tracks an ahoy event" do
          expect{
            get :new
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-new'
          expect(event.properties).to eq({"layout" => "web"})
        end

        context "with bookmarklet url parameters" do
          it "sets attributes from data given as url parameters" do
            get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you"
            expect(assigns(:bookmark).url).to eq "https://www.google.com/"
            expect(assigns(:bookmark).title).to eq "Google: search engine"
            expect(assigns(:bookmark).description).to eq "Find everything and spies on you"
          end

          it "shortens title and description to match model requirement" do
            given_title = "a" * 100
            expected_title = ("a" * 77) + "..."
            description = "b" * 300
            given_description = ("b" * 252) + "..."

            get :new, url: "https://www.google.com/", title: given_title, description: given_description
            expect(assigns(:bookmark).title).to eq expected_title
            expect(assigns(:bookmark).description).to eq given_description
          end

          context "with url parameter layout == popup" do
            it "renders the layout popup" do
              get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup"
              expect(response).to render_template(:new, layout: :popup)
            end

            it "tracks an ahoy event" do
              expect{
                get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", v: "1469795299", layout: "popup"
              }.to change(Ahoy::Event, :count).by(1)
              event = Ahoy::Event.last
              expect(event.name).to eq 'bookmarks-new'
              expect(event.properties).to eq({"layout" => 'popup', "bm_v" => 1469795299, "bm_updated" => true, "duplicate_bookmark_warning" => false})
            end
          end

          context "when the a bookmark with the same url exists" do
            let(:bookmark) { create(:bookmark, user: subject.current_user) }

            it 'displays alert to notify user that the bookmark already exists' do
              get :new, url: bookmark.url, title: "Google: search engine"
              expect(assigns(:bookmark).url).to eq bookmark.url
              expect(flash[:alert]).to eq "#{I18n.t("errors.bookmarks.already_exists")}. #{link_to(I18n.t("errors.bookmarks.see_existing_bookmark"), bookmark_path(bookmark.id), class: 'alert-link')}."
            end
          end
        end

        context "with id parameter" do
          let(:original_bookmark) { create(:bookmark, privacy: 'everyone') }

          it "sets attributes with attributes of the bookmark identified by the id" do
            get :new, id: original_bookmark.id
            new_bookmark = assigns(:bookmark)
            expect(new_bookmark.title).to eq original_bookmark.title
            expect(new_bookmark.description).to eq original_bookmark.description
            expect(new_bookmark.url).to eq original_bookmark.url
            expect(new_bookmark.tag_list).to eq original_bookmark.tag_list
            expect(new_bookmark.copy_from_bookmark_id).to eq original_bookmark.id
          end

          it "tracks an ahoy event" do
            expect{
              get :new, id: original_bookmark.id
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'bookmarks-new'
            expect(event.properties).to eq({"layout" => 'web', "copy_from_bookmark_id" => original_bookmark.id, "duplicate_bookmark_warning" => false})
          end

          context "when the bookmark is not accessible to the user" do
            let(:original_bookmark) { create(:bookmark, privacy: 'only_me') }

            it "redirects the user to the bookmarks list and show an error message" do
              get :new, id: original_bookmark.id
              expect(response).to redirect_to bookmarks_path
              expect(flash[:alert]).to eq I18n.t("pundit.bookmark_policy.show?")
            end
          end
        end

        context "with an old bookmarklet version" do
          it "sets upgrade_bookmarklet in the user session" do
            get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup", v: (Settings.bookmarklet.current_version.to_i - 1000).to_s
            expect(session[:upgrade_bookmarklet]).to be true
          end

          it "tracks an ahoy event" do
            expect{
              get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup", v: (Settings.bookmarklet.current_version.to_i - 1000).to_s
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'bookmarks-new'
            expect(event.properties).to eq({"layout" => 'popup', "bm_v" => (Settings.bookmarklet.current_version.to_i - 1000).to_i, "bm_updated" => false, "duplicate_bookmark_warning" => false})
          end
        end
      end

      context "when the user does not user the bookmarklet on desktop" do
        before(:each) do
          @request.user_agent = user_agent
        end

        context "when user is on desktop and not in the popup" do
          let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:50.0) Gecko/20100101 Firefox/50.0" }

          it "sets @install_bookmarklet to true" do
            get :new
            expect(assigns(:install_bookmarklet)).to be true
          end
        end

        context "when user is on desktop but in the popup" do
          let(:user_agent) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:50.0) Gecko/20100101 Firefox/50.0" }

          it "sets @install_bookmarklet to true" do
            get :new, layout: 'popup'
            expect(assigns(:install_bookmarklet)).to be false
          end
        end

        context "when user is on mobile" do
          let(:user_agent) { "Mozilla/5.0 (Linux; Android 4.4; Nexus 5 Build/_BuildID_) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36" }

          it "sets @install_bookmarklet to false" do
            get :new
            expect(assigns(:install_bookmarklet)).to be false
          end
        end
      end

      it "restricts parameters" do
        params = {url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup"}

        should permit(:title, :description, :url)
        .for(:new, verb: :get, params: params)

        should_not permit(:user_id, :layout)
        .for(:new, verb: :get, params: params)
      end
    end

    describe "GET #edit" do
      context 'when the bookmark belongs to the user' do
        let(:bookmark) { create(:bookmark, user: subject.current_user) }

        it "assigns the requested bookmark as @bookmark and render :edit" do
          get :edit, {:id => bookmark.id}
          expect(assigns(:bookmark)).to eq(bookmark)
        end

        it "tracks an ahoy event" do
          expect{
            get :edit, {:id => bookmark.id}
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-edit'
          expect(event.properties).to eq({"id" => bookmark.id})
        end
      end

      context 'when the bookmark DOES NOT belong to the user' do
        let(:bookmark) { create(:bookmark) }

        it "does not assign the requested bookmark and redirects to the user's bookmarks list" do
          get :edit, {:id => bookmark.id}
          expect(assigns(:bookmark)).not_to eq(bookmark)
          expect(response).to redirect_to bookmarks_path
        end
      end
    end

    describe "POST #create" do

      context "with valid params" do
        it "creates a new Bookmark" do
          expect {
            post :create, {:bookmark => valid_attributes}
          }.to change(Bookmark, :count).by(1)
        end

        it "assigns the current_user as the bookmark's user" do
          post :create, {:bookmark => valid_attributes}
          expect(assigns(:bookmark).user).to eq subject.current_user
        end

        it "assigns a newly created bookmark as @bookmark" do
          original_bookmark = create(:bookmark)
          post :create, {:bookmark => valid_attributes.merge!({copy_from_bookmark_id: original_bookmark.id})}
          created_bookmark = assigns(:bookmark)
          expect(assigns(:bookmark)).to be_a(Bookmark)
          expect(assigns(:bookmark)).to contains_attributes_from valid_attributes.except(:tag_list, :privacy)
          expect(assigns(:bookmark).privacy).to eq valid_attributes[:privacy]
          expect(assigns(:bookmark).tag_list.to_s).to eq valid_attributes[:tag_list].downcase
          expect(assigns(:bookmark).copy_from_bookmark_id).to eq valid_attributes[:copy_from_bookmark_id]
          expect(assigns(:bookmark)).to be_persisted
        end

        it "updates user metadata" do
          post :create, {:bookmark => valid_attributes}
          subject.current_user.metadata.reload
          expect(subject.current_user.metadata.bookmarks_count).to eq 1
        end

        it "redirects to the bookmark page" do
          post :create, {:bookmark => valid_attributes}
          expect(response).to redirect_to bookmark_path(Bookmark.last)
        end

        it "posts a slack notification" do
          expect {
            @bookmark = post :create, {:bookmark => valid_attributes}
          }.to have_enqueued_job(SlackNotifierJob).with { |args|
            expect(args).to eq(["new_bookmark", @bookmark])
          }
        end

        it "tracks an ahoy event" do
          expect{
            @bookmark = post :create, {:bookmark => valid_attributes}
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-create'
          expect(event.properties).to eq({"id" => Bookmark.last.id})
        end

        context "when the bookmark is a copy" do

          it "notifies the original bookmark owner with a bookmark_copy notification" do
            original_bookmark = create(:bookmark)

            expect{
              post :create, {:bookmark => valid_attributes.merge({copy_from_bookmark_id: original_bookmark.id})}
            }.to change(Notification, :count).by(1)

            new_bookmark = Bookmark.last
            notification = Notification.last

            expect(notification.recipient).to eq original_bookmark.user
            expect(notification.sender).to eq new_bookmark.user
            expect(notification.emitter).to eq original_bookmark
            expect(notification.activity).to eq 'bookmark_copy'
          end
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved bookmark as @bookmark" do
          post :create, {:bookmark => invalid_attributes}
          expect(assigns(:bookmark)).to contains_attributes_from invalid_attributes.except(:tag_list, :privacy)
          expect(assigns(:bookmark).privacy).to eq valid_attributes[:privacy]
          expect(assigns(:bookmark).tag_list.to_s).to eq invalid_attributes[:tag_list].downcase
          expect(assigns(:bookmark)).to be_a_new(Bookmark)
          expect(assigns(:bookmark)).not_to be_persisted
        end

        it "re-renders the 'new' template" do
          post :create, {:bookmark => invalid_attributes}
          expect(response).to render_template("new")
        end

        it "does not update user metadata" do
          post :create, {:bookmark => invalid_attributes}
          subject.current_user.metadata.reload
          expect(subject.current_user.metadata.bookmarks_count).to eq 0
        end
      end

      it "restricts parameters" do
        original_bookmark = create(:bookmark)
        params = attributes_for(:bookmark_with_tags, user_id: 1, copy_from_bookmark_id: original_bookmark.id)

        should permit(:title, :description, :url, :tag_list, :privacy, :copy_from_bookmark_id)
        .for(:create, params: {bookmark: params}).on(:bookmark)

        should_not permit(:user_id)
        .for(:create, params: {bookmark: params}).on(:bookmark)
      end
    end

    describe "PUT #update" do
      context 'when the bookmark belongs to the user' do
        let(:bookmark) { create(:bookmark, user: subject.current_user) }

        context "with valid params" do
          let(:new_attributes) { {title: 'new_title', description: 'new_description', url: 'http://new.url' } }

          it "updates the requested bookmark" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            bookmark.reload
            expect(bookmark).to contains_attributes_from new_attributes
          end

          it "assigns the requested bookmark as @bookmark" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(assigns(:bookmark)).to eq(bookmark)
          end

          it "redirects to the bookmark page" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(response).to redirect_to(bookmark_path(bookmark))
          end

          it "tracks an ahoy event" do
            expect{
              put :update, {:id => bookmark.id, :bookmark => new_attributes}
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'bookmarks-update'
            expect(event.properties).to eq({"id" => bookmark.id})
          end
        end

        context "with invalid params" do
          let(:new_attributes) { {title: '', description: 'new_description' } }

          it "assigns the bookmark as @bookmark" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(assigns(:bookmark)).to eq(bookmark)
          end

          it "does not update the bookmark" do
            old_bookmark_attributes = bookmark.attributes.slice('title', 'description')
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(bookmark).to contains_attributes_from old_bookmark_attributes
          end

          it "re-renders the 'edit' template" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(response).to render_template("edit")
          end
        end

        it "restricts parameters" do
          bookmark = create(:bookmark_with_tags, user: subject.current_user)
          params = attributes_for(:bookmark, user_id: 22)

          should permit(:title, :description, :url, :tag_list, :privacy)
          .for(:update, params: {bookmark: params, id: bookmark.id}).on(:bookmark)

          should_not permit(:user_id)
          .for(:update, params: {bookmark: params, id: bookmark.id}).on(:bookmark)
        end
      end

      context 'when the bookmark DOES NOT belong to the user' do
        let(:bookmark) { create(:bookmark) }
        let(:new_attributes) { {title: 'new_title', description: 'new_description', url: 'http://new.url' } }

        it "does not update the bookmark" do
          original_bookmark_attributes = bookmark.attributes
          put :update, {:id => bookmark.id, :bookmark => new_attributes}
          expect(bookmark.reload.attributes).to eq original_bookmark_attributes
        end

        it "does not assign the requested bookmark and redirects to the user's bookmarks list" do
          put :update, {:id => bookmark.id, :bookmark => new_attributes}
          expect(assigns(:bookmark)).not_to eq(bookmark)
          expect(response).to redirect_to bookmarks_path
        end
      end
    end

    describe "DELETE #destroy" do
      let!(:bookmark) { create(:bookmark, user: subject.current_user) }

      context 'when the bookmark belongs to the user' do
        it "destroys the requested bookmark" do
          expect {
            delete :destroy, {:id => bookmark.id}
          }.to change(Bookmark, :count).by(-1)
        end

        it "updates user metadata" do
          UserMetadataUpdater.reset_user_metadatum(subject.current_user)
          delete :destroy, {:id => bookmark.id}
          subject.current_user.metadata.reload
          expect(subject.current_user.metadata.bookmarks_count).to eq 0
        end

        it "tracks an ahoy event" do
          expect{
            delete :destroy, {:id => bookmark.id}
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'bookmarks-destroy'
          expect(event.properties).to eq({"id" => bookmark.id})
        end
      end

      context 'when the bookmark DOES NOT belong to the user' do
        let!(:bookmark) { create(:bookmark) }

        it "does not destroy the requested bookmark" do
          expect {
            delete :destroy, {:id => bookmark.id}
          }.to change(Bookmark, :count).by(0)
        end

        it "does not update user metadata" do
          UserMetadataUpdater.reset_user_metadatum(bookmark.user)
          delete :destroy, {:id => bookmark.id}
          bookmark.user.metadata.reload
          expect(bookmark.user.metadata.bookmarks_count).to eq 1
        end
      end

      it "redirects to the bookmarks list" do
        delete :destroy, {:id => bookmark.id}
        expect(response).to redirect_to(bookmarks_url)
      end
    end
  end
end
