RSpec.shared_examples "a controller requiring an authenticated user" do |resource_name|

  # Return true if this controller has the following action method defined
  def self.has_action_method?(method_name)
    described_class.action_methods.include?(method_name.to_s)
  end

  it { should use_before_filter(:authenticate_user!) }

  context "without a signed_in user" do
    before(:each) { sign_out :user }

    describe "GET #index", :if => self.has_action_method?('index') do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #show", :if => self.has_action_method?('show') do
      it "redirects to new_user_session_path" do
        get :show, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #new", :if => self.has_action_method?('new') do
      it "redirects to new_user_session_path" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #edit", :if => self.has_action_method?('edit') do
      it "redirects to new_user_session_path" do
        get :edit, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST #create", :if => self.has_action_method?('create') do
      it "redirects to new_user_session_path" do
        post :create
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "PUT #update", :if => self.has_action_method?('update') do
      it "redirects to new_user_session_path" do
        put :update, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "DELETE #destroy", :if => self.has_action_method?('destroy') do
      it "redirects to new_user_session_path" do
        delete :destroy, {id: 1}
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
