require 'rails_helper'

RSpec.describe AutocompleteSearchController, type: :controller do
  include Helpers

  context 'without a signed_in user' do
    describe "GET #tags" do
      it "replies with a 401" do
        get :tags, format: :json
        expect(response.status).to eq 401
        expect(response_body).to eq({"error" => I18n.t("devise.failure.unauthenticated")})
      end
    end

    describe "GET #username_available" do
      it "replies with a 401" do
        get :username_available, format: :json
        expect(response.status).to eq 401
        expect(response_body).to eq({"error" => I18n.t("devise.failure.unauthenticated")})
      end
    end
  end

  context 'with a signed_in user' do
    let(:current_user) { create(:user_profile, username: 'james').user }
    let(:other_user) { create(:user_profile, username: 'johnsnow').user }

    before(:each) { sign_in_user(current_user) }

    describe 'GET #tags' do
      before(:each) do
        create(:bookmark, tag_list: 'rails1, rails2, rails3', user: current_user)
        create(:bookmark, tag_list: 'rails1, rails2, rails4', user: current_user)
        create(:bookmark, tag_list: 'rails2, rails5, rails6', user: current_user)

        # Another user create bookmarks with the tag rails7. It shouldn't appear in the list
        create(:bookmark, tag_list: 'rails7', user: other_user)
        create(:bookmark, tag_list: 'rails7', user: other_user)
        create(:bookmark, tag_list: 'rails7', user: other_user)
      end

      context 'when no query parameter is given' do
        it 'returns an empty array' do
          get :tags, format: :json
          expect(response_body).to eq []
        end
      end

      context 'when a query parameter :q is given' do
        context 'when :q matches tags' do
          it 'returns the list of tags created but the current_user matching the query' do
            get :tags, format: :json, q: 'ra'
            expect(response_body).to be_a Array
            expect(response_body[0]).to eq 'rails2'
            expect(response_body[1]).to eq 'rails1'
            expect(response_body.count).to eq 5
          end
        end

        context 'when :q matches nothing' do
          it 'returns an empty array' do
            get :tags, format: :json, q: 'to'
            expect(response_body).to eq []
          end
        end

        context 'when :q has less than 2 characters' do
          it 'returns an empty array' do
            get :tags, format: :json, q: 'r'
            expect(response_body).to eq []
          end
        end
      end
    end

    describe 'GET #username_available' do
      let!(:other_user_profile) { create(:user_profile) }

      context 'when :q has less than 5 characters' do
        it 'returns false' do
          get :username_available, format: :json, q: 'lisa'
          expect(response_body).to eq({"valid" => false, "message" => "lisa is too short (minimum is 5 characters)"})
        end
      end

      context 'when username is already taken' do
        context 'when it\'s not the current_user username' do
          it 'returns false' do
            get :username_available, format: :json, q: other_user_profile.username
            expect(response_body).to eq ({"valid" => false, "message" => "#{other_user_profile.username} has already been taken"})
          end
        end

        context 'when it is the current_user username' do
          it 'returns true' do
            get :username_available, format: :json, q: current_user.user_profile.username
            expect(response_body).to eq ({"valid" => true, "message" => I18n.t("user_profiles.form.username_available", username: current_user.user_profile.username)})
          end
        end
      end

      context 'when the username is available' do
        it 'returns true' do
          get :username_available, format: :json, q: 'johnsnow'
          expect(response_body).to eq ({"valid" => true, "message" => I18n.t("user_profiles.form.username_available", username: 'johnsnow')})
        end
      end
    end
  end
end
