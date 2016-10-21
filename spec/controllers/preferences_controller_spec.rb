require 'rails_helper'

RSpec.describe PreferencesController, type: :controller do
  context "without a signed_in user" do
    describe "GET #edit" do
      it "redirects to new_user_session_path" do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PUT #update" do
      it "redirects to new_user_session_path" do
        put :update, {user_preferences: {search_engine_index: false}}
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context "with a signed_in user" do
    before(:each) { sign_in_user }

    describe "GET #edit" do
      it "assign the current_user's preferences to @preference" do
        get :edit
        expect(assigns(:preference)).to eq subject.current_user.preferences
      end

      it 'tracks an ahoy event' do
        expect{
          get :edit
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'user_preferences-edit'
        expect(event.properties).to eq({"user_id" => subject.current_user.id})
      end
    end

    describe "PUT #update" do
      context "with valid parameters" do
        let(:params) { {user_preference: {search_engine_index: false, public_profile: false}} }

        it 'updates the current_user preferences' do
          subject.current_user.preferences.update_attributes({search_engine_index: true, public_profile: true})
          put :update, params
          expect(subject.current_user.preferences.slice(:search_engine_index, :public_profile)).to eq({"search_engine_index" => false, "public_profile" => false})
        end

        it 'assigns updated preferences to preference' do
          subject.current_user.preferences.update_attributes({search_engine_index: true, public_profile: true})
          put :update, params
          expect(assigns(:preference).slice(:search_engine_index, :public_profile)).to eq({"search_engine_index" => false, "public_profile" => false})
        end

        it 'redirects to the edit_preferences page with a notice' do
          put :update, params
          expect(response).to redirect_to(edit_preferences_path)
          expect(flash[:notice]).to eq I18n.t('notices.user_preferences_updated')
        end

        it "tracks an ahoy event" do
          expect{
            put :update, params
          }.to change(Ahoy::Event, :count).by(1)
          event = Ahoy::Event.last
          expect(event.name).to eq 'user_preferences-update'
          expect(event.properties).to eq({"user_id" => subject.current_user.id})
        end
      end      
    end
  end
end
