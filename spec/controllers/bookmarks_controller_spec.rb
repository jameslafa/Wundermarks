require 'rails_helper'

RSpec.describe BookmarksController, type: :controller do
  let(:valid_attributes) { attributes_for(:bookmark_with_tags) }
  let(:invalid_attributes) { attributes_for(:bookmark_with_tags, title: '') }

  context "without a signed_in user" do
    before(:each) { sign_out :user }
    let(:bookmark) { create(:bookmark) }

    describe "GET #index" do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show" do
      it "renders template :show" do
        get :show, {id: bookmark.id}
        expect(response).to render_template :show
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
    login_user

    describe "GET #index" do
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

      context 'when a query parameter is defined' do
        before(:each) do
          @tag = 'my new tag'
          @searched_bookmark = current_user_bookmarks.second
          @searched_bookmark.update_attributes({tag_list: "#{@searched_bookmark.tag_list.to_s}, #{@tag}"})
        end

        it "assigns all bookmarks matching the search results belonging to the current user" do
          get :index, q: @tag
          expect(assigns(:bookmarks)).to eq([@searched_bookmark])
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
    end

    describe "GET #new" do
      it "assigns a new bookmark as @bookmark" do
        get :new
        expect(assigns(:bookmark)).to be_a_new(Bookmark)
      end

      context "with url parameters" do
        it "prefills field with data given as url parameters" do
          get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you"
          expect(assigns(:bookmark).url).to eq "https://www.google.com/"
          expect(assigns(:bookmark).title).to eq "Google: search engine"
          expect(assigns(:bookmark).description).to eq "Find everything and spies on you"
        end

        context "with url parameter layout == popup" do
          it "renders the layout popup" do
            get :new, url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup"
            expect(response).to render_template(:new, layout: :popup)
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
          post :create, {:bookmark => valid_attributes}
          created_bookmark = assigns(:bookmark)
          expect(assigns(:bookmark)).to be_a(Bookmark)
          expect(assigns(:bookmark)).to contains_attributes_from valid_attributes.except(:tag_list)
          expect(assigns(:bookmark).tag_list.to_s).to eq valid_attributes[:tag_list].downcase
          expect(assigns(:bookmark)).to be_persisted
        end

        it "redirects to the bookmarks list" do
          post :create, {:bookmark => valid_attributes}
          expect(response).to redirect_to bookmarks_path
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved bookmark as @bookmark" do
          post :create, {:bookmark => invalid_attributes}
          expect(assigns(:bookmark)).to contains_attributes_from invalid_attributes.except(:tag_list)
          expect(assigns(:bookmark).tag_list.to_s).to eq invalid_attributes[:tag_list].downcase
          expect(assigns(:bookmark)).to be_a_new(Bookmark)
          expect(assigns(:bookmark)).not_to be_persisted
        end

        it "re-renders the 'new' template" do
          post :create, {:bookmark => invalid_attributes}
          expect(response).to render_template("new")
        end
      end

      it "restricts parameters" do
        params = attributes_for(:bookmark_with_tags, user_id: 1)

        should permit(:title, :description, :url, :tag_list)
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

          it "redirects to the bookmark" do
            put :update, {:id => bookmark.id, :bookmark => new_attributes}
            expect(response).to redirect_to(bookmarks_path)
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

          should permit(:title, :description, :url, :tag_list)
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
      end

      context 'when the bookmark DOES NOT belong to the user' do
        let!(:bookmark) { create(:bookmark) }

        it "does not destroy the requested bookmark" do
          expect {
            delete :destroy, {:id => bookmark.id}
          }.to change(Bookmark, :count).by(0)
        end
      end

      it "redirects to the bookmarks list" do
        delete :destroy, {:id => bookmark.id}
        expect(response).to redirect_to(bookmarks_url)
      end
    end
  end
end
