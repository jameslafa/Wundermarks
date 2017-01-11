require 'rails_helper'

RSpec.describe Admin::UserAnalysesController, type: :controller do

  describe "GET #last_connections" do
    context "when the user is signed in" do
      context "when the user is not an admin" do
        before(:each) { sign_in_user }

        it "redirects the user to a new_user_session_path" do
          get :last_connections
          expect(response).to redirect_to new_user_session_path
        end
      end

      context "when the user is an admin" do
        before(:each) { sign_in_admin }

        it "renders the last_connections template" do
          get :last_connections
          expect(response).to render_template :last_connections
        end
      end
    end

    context "when user is not signed in" do
      it "redirects the user to a new_user_session_path" do
        get :last_connections
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

end
