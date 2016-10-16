require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid attributes' do # include user_profile.name
      let(:valid_params) { {email: "john.snow2@gmail.com", password: 'admin_123', password_confirmation: 'admin_123', user_profile_attributes: {name: 'John Snow'}} }

      it 'creates the user and user_profile' do
        expect{
          post :create, {user: valid_params}
        }.to change(User, :count).by(1)
        .and change(UserProfile, :count).by(1)

        expect(UserProfile.last.user_id).to eq(User.last.id)
      end

      it 'redirects to the edit profile page' do
        post :create, {user: valid_params}
        expect(response).to redirect_to edit_current_user_profile_path
      end

      it "posts a slack notification" do
        expect {
          @user = post :create, {user: valid_params}
        }.to have_enqueued_job(SlackNotifierJob).with { |args|
          expect(args).to eq(["new_user_registration", @user])
        }
      end

      it "tracks an ahoy event" do
        expect{
          @user = post :create, {user: valid_params}
        }.to change(Ahoy::Event, :count).by(1)
        event = Ahoy::Event.last
        expect(event.name).to eq 'registrations-create'
        expect(event.properties).to eq({"user_id" => User.last.id })
      end
    end

    context 'with invalid attributes' do # no user_profile.name
      let(:invalid_params) { {email: "john.snow2@gmail.com", password: 'admin_123', password_confirmation: 'admin_123', user_profile_attributes: {name: ''}} }

      it 're-render the sign_up with @user set' do
        post :create, {user: invalid_params}
        expect(response).to render_template :new
        user = assigns(:user)
        expect(user.email).to eq invalid_params[:email]
        expect(user.user_profile.name).to eq invalid_params[:user_profile_attributes][:name]
      end

      it 'show error messages' do
        post :create, {user: invalid_params}
        error_messages = assigns(:user).errors.messages
        expect(error_messages).to have_key :"user_profile.name"
        expect(error_messages[:"user_profile.name"]).to include I18n.t('errors.messages.blank')
      end

      it 'does not create user nor user_profile' do
        expect{
            post :create, {user: invalid_params}
        }.to change(User, :count).by(0)
        .and change(UserProfile, :count).by(0)
      end
    end
  end

  describe 'sign_up_params' do
    it 'permits nested user_profile attributes' do
      params = {email: "john.snow2@gmail.com", password: 'admin_123', password_confirmation: 'admin_123', user_profile_attributes: {name: 'John Snow'}}

      should permit(:email, :password, :password_confirmation, user_profile_attributes: [:name])
      .for(:create, params: {user: params}).on(:user)
    end
  end
end
