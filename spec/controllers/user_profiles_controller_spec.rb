require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do

  describe "GET #show" do
    context "when :id is defined" do
      let(:profile) { create(:user_profile) }

      it "assigns to @profile the profile identified by :id" do
        get :show, {id: profile.id}
        expect(assigns(:profile)).to eq profile
      end
    end

    context "when :id is nil" do
      login_user
      let!(:other_profiles) { create_list(:user_profile, 2) }
      let!(:profile) { create(:user_profile, user_id: subject.current_user.id) }

      it "assigns to @profile the profile of the current_user" do
        get :show
        expect(assigns(:profile)).to eq profile
      end
    end
  end

  describe "GET #edit" do
    context "when the user is logged in" do
      login_user

      let!(:profile) { create(:user_profile, user: subject.current_user) }

      it "assigns the current_user's profile to @profile" do
        get :edit
        expect(assigns(:profile)).to eq profile
      end
    end

    context "when the user is NOT logged in" do
      it "redirects the user to the login page" do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #update" do
    context "when the user is logged in" do
      login_user
      let!(:current_user_profile) { create(:user_profile, user: subject.current_user) }

      context "with valid params" do
        let(:new_attributes) { {name: 'John Snow', introduction: 'I like women with red hairs' } }

        it "updates the current_user's profile" do
          put :update, user_profile: new_attributes
          current_user_profile.reload
          expect(current_user_profile.name).to eq new_attributes[:name]
          expect(current_user_profile.introduction).to eq new_attributes[:introduction]
        end

        it "redirects to the profile" do
          put :update, user_profile: new_attributes
          expect(response).to redirect_to current_user_profile_path
        end
      end

      context "with invalid params" do
        let(:new_attributes) { {name: '', introduction: 'I still like women with red hairs' } }

        it "assigns the profile as @profile with new values" do
          put :update, user_profile: new_attributes
          profile = assigns(:profile)
          expect(profile.name).to eq new_attributes[:name]
          expect(profile.introduction).to eq new_attributes[:introduction]
        end

        it "does not update the profile" do
          old_attributes = current_user_profile.attributes.slice
          put :update, user_profile: new_attributes
          current_user_profile.reload
          expect(current_user_profile).to contains_attributes_from old_attributes
        end

        it "re-renders the 'edit' template" do
          put :update, user_profile: new_attributes
          expect(response).to render_template :edit
        end
      end

      it "restricts parameters" do
        profile = create(:user_profile, user: subject.current_user)
        params = attributes_for(:user_profile, user_id: 22)

        should permit(:name, :introduction)
        .for(:update, params: {user_profile: params, user_id: subject.current_user.id}).on(:user_profile)

        should_not permit(:user_id)
        .for(:update, params: {user_profile: params, user_id: subject.current_user.id}).on(:user_profile)
      end
    end

    context "when the user is NOT logged in" do
      it "redirects the user to the login page" do
        put :update, user_profile: {name: 'John Snow', introduction: 'I like women with red hairs' }
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
