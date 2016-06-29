RSpec.shared_examples "a controller requiring an authenticated user" do |resource_name|

  it { should use_before_filter(:authenticate_user!) }

  context "without a signed_in user" do
    before(:each) { sign_out :user }

    describe "GET #index" do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show" do
      it "redirects to new_user_session_path" do
        get :show, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #new" do
      it "redirects to new_user_session_path" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #edit" do
      it "redirects to new_user_session_path" do
        get :edit, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST #create" do
      it "redirects to new_user_session_path" do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PUT #update" do
      it "redirects to new_user_session_path" do
        put :update, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "DELETE #destroy" do
      it "redirects to new_user_session_path" do
        delete :destroy, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
