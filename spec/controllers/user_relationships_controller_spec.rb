require 'rails_helper'

RSpec.describe UserRelationshipsController, type: :controller do

  describe "POST #create" do
    context "when the user is signed in" do
      let!(:current_user) {create(:user)}
      before(:each) { sign_in_user(current_user) }

      context "when a user_id is provided" do
        let!(:other_user_profile) {create(:user_profile)}
        let(:other_user) {other_user_profile.user}

        it "creates a new user_relationship: current_user -> other_user" do
          expect{
            post :create, user_id: other_user.id
          }.to change(Follow, :count).by(1)

          expect(current_user.following?(other_user)).to be true
        end

        it "redirects to the other_user profile page" do
          post :create, user_id: other_user.id
          expect(response).to redirect_to user_profile_path(id: other_user_profile.username)
        end

        it "tracks an ahoy event" do
          expect{
            post :create, user_id: other_user.id
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'user_relationships-create'
          expect(event.properties).to eq({"current_user" => current_user.id, "id" => other_user.id })
        end
      end

      context "when no user_id is provided" do
        it "returns a ActiveRecord::RecordNotFound error" do
          expect{
            post :create
          }.to raise_error(ActiveRecord::RecordNotFound)

          expect{
            post :create, user_id: ""
          }.to raise_error(ActiveRecord::RecordNotFound)
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
      before(:each) {
        sign_in_user(current_user)
      }

      context "when an id is provided" do
        let!(:other_user_profile) {create(:user_profile)}
        let(:other_user) {other_user_profile.user}

        context "when the user_relationship exists" do
          before { current_user.follow(other_user) }

          it "removes the user relationships with the other_user" do
            expect{
              delete :destroy, id: other_user.id
            }.to change(Follow, :count).by(-1)

            expect(current_user.following?(other_user)).to be false
          end

          it "redirects to the other_user profile page" do
            delete :destroy, id: other_user.id
            expect(response).to redirect_to user_profile_path(id: other_user_profile.username)
          end

          it "tracks an ahoy event" do
            expect{
              delete :destroy, id: other_user.id
            }.to change(Ahoy::Event, :count).by(1)
            event = Ahoy::Event.last
            expect(event.name).to eq 'user_relationships-destroy'
            expect(event.properties).to eq({"current_user" => current_user.id, "id" => other_user.id })
          end
        end

        context "when the user_relationship does not exist" do
          it "redirects to the other_user profile page" do
            delete :destroy, id: other_user.id
            expect(response).to redirect_to user_profile_path(id: other_user_profile.username)
          end
        end
      end

      context "when non existing id is provided" do
        it "returns a ActiveRecord::RecordNotFound error" do
          expect{
            delete :destroy, id: "123"
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

    end
    context "when the user is not signed in" do
      it "redirects to new_user_session_path" do
        delete :destroy, id: "1"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
