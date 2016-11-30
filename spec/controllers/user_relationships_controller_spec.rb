require 'rails_helper'

RSpec.describe UserRelationshipsController, type: :controller do

  describe "POST #create" do
    context "when the user is signed in" do
      let!(:current_user) {create(:user)}
      let!(:other_user_profile) {create(:user_profile)}
      let(:other_user) {other_user_profile.user}

      before(:each) { sign_in_user(current_user) }

      it "tracks an ahoy event" do
        expect{
          post :create, user_id: other_user.id
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'user_relationships-create'
        expect(event.properties).to eq({"current_user" => current_user.id, "id" => other_user.id })
      end

      context "when the user_relationship does not already exist" do
        it "creates a new user_relationship: current_user -> other_user" do
          expect{
            post :create, user_id: other_user.id
          }.to change(Follow, :count).by(1)

          expect(current_user.following?(other_user)).to be true
          expect(assigns(:following)).to be true
        end

        it "updates the user metadata counters" do
          current_user_followings_count = current_user.metadata.followings_count
          other_user_followers_count = other_user.metadata.followers_count

          post :create, user_id: other_user.id

          expect(current_user.metadata.reload.followings_count).to eq(current_user_followings_count + 1)
          expect(other_user.metadata.reload.followers_count).to eq(other_user_followers_count + 1)
        end
      end

      context "when the user_relationship does already exist" do
        before(:each) do
          current_user.follow(other_user)
        end

        it "does not create a new user_relationship: current_user -> other_user" do
          expect{
            post :create, user_id: other_user.id
          }.to change(Follow, :count).by(0)

          expect(current_user.following?(other_user)).to be true
          expect(assigns(:following)).to be true
        end

        it "does not update the user metadata counters" do
          current_user_followings_count = current_user.metadata.followings_count
          other_user_followers_count = other_user.metadata.followers_count

          post :create, user_id: other_user.id

          expect(current_user.metadata.reload.followings_count).to eq(current_user_followings_count)
          expect(other_user.metadata.reload.followers_count).to eq(other_user_followers_count)
        end
      end

      context "when request format is :js" do
        context "when a valid user_id is provided" do
          it "assigns @user_id with the other_user id and render template :follow" do
            post :create, user_id: other_user.id, format: :js
            expect(assigns(:user_id)).to eq other_user.id
            expect(response).to render_template :follow
          end
        end

        context "when non existing user_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              post :create, user_id: "123", format: :js
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when request format is :html" do
        context "when a user_id is provided" do
          it "redirects to the other_user profile page" do
            post :create, user_id: other_user.id
            expect(response).to redirect_to user_profile_path(id: other_user_profile.username)
          end
        end

        context "when non existing user_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              post :create, user_id: "123"
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to new_user_session_path" do
        post :create, user_id: "1"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    context "when the user is signed in" do
      let!(:current_user) {create(:user)}
      let!(:other_user_profile) {create(:user_profile)}
      let(:other_user) {other_user_profile.user}

      before(:each) { sign_in_user(current_user) }

      it "tracks an ahoy event" do
        expect{
          delete :destroy, user_id: other_user.id
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'user_relationships-destroy'
        expect(event.properties).to eq({"current_user" => current_user.id, "id" => other_user.id })
      end

      context "when the user_relationship does exist" do
        before(:each) do
          current_user.follow(other_user)
        end

        it "destroy the user_relationship: current_user -> other_user" do
          expect{
            delete :destroy, user_id: other_user.id
          }.to change(Follow, :count).by(-1)

          expect(current_user.following?(other_user)).to be false
          expect(assigns(:following)).to be false
        end

        it "updates the user metadata counters" do
          current_user_followings_count = current_user.metadata.followings_count
          other_user_followers_count = other_user.metadata.followers_count

          delete :destroy, user_id: other_user.id

          expect(current_user.metadata.reload.followings_count).to eq(current_user_followings_count - 1)
          expect(other_user.metadata.reload.followers_count).to eq(other_user_followers_count - 1)
        end
      end

      context "when the user_relationship does not exist" do

        it "assign following to false" do
          delete :destroy, user_id: other_user.id
          expect(current_user.following?(other_user)).to be false
          expect(assigns(:following)).to be false
        end

        it "does not update the user metadata counters" do
          current_user_followings_count = current_user.metadata.followings_count
          other_user_followers_count = other_user.metadata.followers_count

          delete :destroy, user_id: other_user.id

          expect(current_user.metadata.reload.followings_count).to eq(current_user_followings_count)
          expect(other_user.metadata.reload.followers_count).to eq(other_user_followers_count)
        end
      end

      context "when request format is :js" do
        context "when a valid user_id is provided" do
          it "assigns @user_id with the other_user id and render template :follow" do
            delete :destroy, user_id: other_user.id, format: :js
            expect(assigns(:user_id)).to eq other_user.id
            expect(response).to render_template :follow
          end
        end

        context "when non existing user_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              delete :destroy, user_id: "123", format: :js
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when request format is :html" do
        context "when a user_id is provided" do
          it "redirects to the other_user profile page" do
            post :create, user_id: other_user.id
            expect(response).to redirect_to user_profile_path(id: other_user_profile.username)
          end
        end

        context "when non existing user_id is provided" do
          it "returns a ActiveRecord::RecordNotFound error" do
            expect{
              post :create, user_id: "123"
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end

    context "when the user is not signed in" do
      it "redirects to new_user_session_path" do
        post :create, user_id: "1"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
