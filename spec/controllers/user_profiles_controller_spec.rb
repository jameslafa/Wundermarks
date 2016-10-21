require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do

  describe "GET #show" do
    context "when :id is defined" do
      let(:profile) { create(:user_profile) }

      context 'when the :id is an integer' do
        it "assigns to @profile the profile identified by :id" do
          get :show, {id: profile.id}
          expect(assigns(:profile)).to eq profile
        end

        it "tracks an ahoy event" do
          expect{
            get :show, {id: profile.id}
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'user_profiles-show'
          expect(event.properties).to eq({"id" => profile.id, "current_user" => false })
        end

        it "assigns @statistics with the user's profile statistics" do
          get :show, {id: profile.id}
          expect(assigns(:statistics)).to be_a Hash
          expect(assigns(:statistics)).to be_has_key 'bookmarks_count'
          expect(assigns(:statistics)).to be_has_key 'followers_count'
          expect(assigns(:statistics)).to be_has_key 'following_count'
        end
      end

      context 'when the :id is a string' do
        it "assigns to @profile the profile identified by :username" do
          get :show, {id: profile.username}
          expect(assigns(:profile)).to eq profile
        end
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

    context "when the profile is someone else's user" do
      let!(:other_profile) { create(:user_profile) }
      let!(:public_bookmarks) { create_list(:bookmark_visible_to_everyone, 2, user: other_profile.user) }
      let!(:private_bookmarks) { create_list(:bookmark_visible_to_only_me, 2, user: other_profile.user) }

      context "when the user is logged in" do
        login_user

        it "assigns only visible bookmarks to @bookmarks" do
          get :show, {id: other_profile.id}
          expect(assigns(:bookmarks)).to match_array public_bookmarks
        end

        context "and already follows the user" do
          it 'sets @following to true' do
            subject.current_user.follow other_profile.user
            get :show, {id: other_profile.id}
            expect(assigns(:following)).to be true
          end
        end

        context "and does not follow the user" do
          it 'sets @following to false' do
            get :show, {id: other_profile.id}
            expect(assigns(:following)).to be false
          end
        end
      end

      context "when the user is NOT logged in" do
        context "when user's preferences allow public viewing" do
          it "assigns only visible bookmarks to @bookmarks" do
            get :show, {id: other_profile.id}
            expect(assigns(:bookmarks)).to match_array public_bookmarks
          end
        end

        context "when user's preferences does now allow public viewing" do
          it "does not assign bookmarks" do
            other_profile.user.preferences.update_attributes({:public_profile => false})
            get :show, {id: other_profile.id}
            expect(assigns(:public_profile)).to eq false
            expect(assigns(:bookmarks)).to be_nil
            expect(assigns(:statistics)).to be_nil
          end
        end
      end
    end

    context "when the profile is the current_user's profile" do
      login_user
      let!(:profile) { create(:user_profile, user_id: subject.current_user.id) }
      let!(:public_bookmarks) { create_list(:bookmark_visible_to_everyone, 2, user: profile.user) }
      let!(:private_bookmarks) { create_list(:bookmark_visible_to_only_me, 2, user: profile.user) }

      it "assigns public and private bookmarks to @bookmarks" do
        get :show, {id: profile.id}
        expect(assigns(:bookmarks)).to match_array (public_bookmarks + private_bookmarks)
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

      it "tracks an ahoy event" do
        expect{
          get :edit
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'user_profiles-edit'
        expect(event.properties).to eq({"id" => profile.id})
      end
    end

    context "when the user is NOT logged in" do
      it "redirects the user to the login page" do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT #update" do
    context "when the user is logged in" do
      login_user
      let!(:current_user_profile) { create(:user_profile, user: subject.current_user) }

      context "with valid params" do
        let(:new_attributes) { {name: 'John Snow', introduction: 'I like women with red hairs',
          country: 'FR', city: 'Lyon', website: 'http://google.com', birthday: '1988-12-23',
          twitter_username: 'johnsnow', github_username: 'johnsnow' } }

        it "updates the current_user's profile" do
          put :update, user_profile: new_attributes
          current_user_profile.reload
          expect(current_user_profile.name).to eq new_attributes[:name]
          expect(current_user_profile.introduction).to eq new_attributes[:introduction]
          expect(current_user_profile.country).to eq new_attributes[:country]
          expect(current_user_profile.city).to eq new_attributes[:city]
          expect(current_user_profile.website).to eq new_attributes[:website]
          expect(current_user_profile.birthday).to eq Date.strptime(new_attributes[:birthday], "%Y-%m-%d")
          expect(current_user_profile.twitter_username).to eq new_attributes[:twitter_username]
          expect(current_user_profile.github_username).to eq new_attributes[:github_username]
        end

        it "redirects to the profile" do
          put :update, user_profile: new_attributes
          expect(response).to redirect_to current_user_profile_path
        end

        it "tracks an ahoy event" do
          expect{
            put :update, user_profile: new_attributes
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'user_profiles-update'
          expect(event.properties).to eq({"id" => current_user_profile.id})
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

        should permit(:name, :introduction, :username, :country, :city, :website,
        :birthday, :twitter_username, :github_username, :avatar, :avatar_cache)
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
