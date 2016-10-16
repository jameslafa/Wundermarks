require 'rails_helper'

RSpec.describe HomeController, type: :controller do

  describe "GET #index" do
    context "when the user is not signed_in" do
      it "assigns a new user with a profile" do
        get :index
        expect(assigns(:user)).to be_a_new User
        expect(assigns(:user).user_profile).to be_a_new UserProfile
      end

      it "renders the index template with homepage layout" do
        get :index
        expect(response).to render_template(:index, :layout => "homepage")
      end
    end

    context "when the user is signed_in" do
      before(:each) { sign_in_user }

      context 'without no_redirect=1' do
        it "redirects the user to his feed" do
          get :index
          expect(response).to redirect_to feed_path
        end
      end

      context 'with no_redirect=1' do
        it "renders the index template with homepage layout" do
          get :index, no_redirect: "1"
          expect(response).to render_template(:index, :layout => "homepage")
        end
      end
    end
  end
end
