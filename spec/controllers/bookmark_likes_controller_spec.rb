require 'rails_helper'

RSpec.describe BookmarkLikesController, type: :controller do

  describe "POST #create" do
    context "when the user is signed in" do
      let!(:current_user_profile) { create(:user_profile)}
      let!(:current_user) { current_user_profile.user }

      let(:bookmark) { create(:bookmark) }

      before(:each) { sign_in_user(current_user) }

      it "tracks an ahoy event" do
        expect{
          post :create, bookmark_id: bookmark.id
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'bookmark_likes-create'
        expect(event.properties).to eq({"current_user" => current_user.id, "bookmark_id" => bookmark.id })
      end

      context "when the user has NOT already liked the bookmark" do
        it "creates a new BookmarkLike" do
          expect{
            post :create, bookmark_id: bookmark.id
          }.to change(BookmarkLike, :count).by(1)

          bookmark_like = BookmarkLike.last
          expect(bookmark_like.bookmark).to eq bookmark
          expect(bookmark_like.user).to eq current_user
        end

        it "creates a bookmark_like notification" do
          expect{
            post :create, bookmark_id: bookmark.id
          }.to change(Notification, :count).by(1)

          notification = Notification.last

          expect(notification.recipient).to eq bookmark.user
          expect(notification.sender).to eq subject.current_user
          expect(notification.emitter).to eq bookmark
          expect(notification.activity).to eq 'bookmark_like'
        end

        context "when the user likes his own bookmark" do
          let(:bookmark) { create(:bookmark, user: current_user) }

          it "does not create a new BookmarkLike" do
            expect{
              post :create, bookmark_id: bookmark.id
            }.not_to change(BookmarkLike, :count)
          end
        end
      end

      context "when the user has already liked the bookmark" do
        it "does not create a new BookmarkLike" do
          bookmark.likes.create(user: current_user)

          expect{
            post :create, bookmark_id: bookmark.id
          }.not_to change(BookmarkLike, :count)
        end
      end

      context "when request format is :js" do
        it "renders template :like" do
          post :create, bookmark_id: bookmark.id, format: :js
          expect(assigns(:bookmark)).to eq bookmark
          expect(response).to render_template :like
        end

        context "when non existing bookmark_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              post :create, bookmark_id: "123", format: :js
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when request format is :html" do
        it "redirects to the bookmark show page" do
          post :create, bookmark_id: bookmark.id
          expect(response).to redirect_to bookmark_path(id: bookmark.id)
        end

        context "when non existing bookmark_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              post :create, bookmark_id: "123"
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to new_user_session_path" do
        post :create, bookmark_id: "1"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the user is signed in" do
      let!(:current_user_profile) { create(:user_profile)}
      let!(:current_user) { current_user_profile.user }

      let(:bookmark) { create(:bookmark) }
      let(:bookmark_like) {create(:bookmark_like, bookmark: bookmark, user: current_user)}

      before(:each) { sign_in_user(current_user) }

      it "tracks an ahoy event" do
        expect{
          delete :destroy, bookmark_id: bookmark_like.bookmark_id
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'bookmark_likes-destroy'
        expect(event.properties).to eq({"current_user" => current_user.id, "bookmark_id" => bookmark.id })
      end

      context "when the user has already liked the bookmark" do
        it "destroys the BookmarkLike" do
          bookmark_like
          expect{
            delete :destroy, bookmark_id: bookmark_like.bookmark_id
          }.to change(BookmarkLike, :count).by(-1)
        end
      end

      context "when the user has NOT already liked the bookmark" do
        it "does not destroy any BookmarkLike" do
          expect{
            delete :destroy, bookmark_id: bookmark.id
          }.not_to change(BookmarkLike, :count)
        end
      end

      context "when request format is :js" do
        it "renders template :like" do
          delete :destroy, bookmark_id: bookmark.id, format: :js
          expect(assigns(:bookmark)).to eq bookmark
          expect(response).to render_template :like
        end

        context "when non existing bookmark_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              delete :destroy, bookmark_id: "123", format: :js
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when request format is :html" do
        it "redirects to the bookmark show page" do
          delete :destroy, bookmark_id: bookmark.id
          expect(response).to redirect_to bookmark_path(id: bookmark.id)
        end

        context "when non existing bookmark_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              delete :destroy, bookmark_id: "123"
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to new_user_session_path" do
        delete :destroy, bookmark_id: "1"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
