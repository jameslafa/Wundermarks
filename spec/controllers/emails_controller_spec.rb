require 'rails_helper'

RSpec.describe EmailsController, type: :controller do
  context "without a signed_in user" do
    before(:each) { sign_out :user }

    describe "GET #new" do
      it "redirects to new_user_session_path" do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #create" do
      it "redirects to new_user_session_path" do
        post :create, {}
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context "with a signed_in user" do
    login_user

    describe "GET #new" do
      it "assigns a new bookmark as @bookmark" do
        get :new
        expect(assigns(:email)).to be_a_new(Email)
      end
    end

    describe "POST #create" do
      before(:each) do
        allow_any_instance_of(Email).to receive(:deliver_now).and_return(true)
      end

      let(:valid_attributes) { attributes_for(:email).except(:user_id) }
      let(:invalid_attributes) { attributes_for(:email, from: '').except(:user_id) }

      context "with valid params" do
        it "creates a new Email" do
          expect {
            post :create, {:email => valid_attributes}
          }.to change(Email, :count).by(1)
        end

        it "sends the email" do
          expect_any_instance_of(Email).to receive(:deliver_now)
          post :create, {:email => valid_attributes}
        end

        it "renders template sent" do
          post :create, {:email => valid_attributes}
          expect(response).to render_template :sent
        end
      end

      # it "restricts parameters" do
      #   params = {from: "john.snow@gmail.com", to: "batman@gmail.com", subject: "subject", text: "message"}
      #
      #   should permit(:from, :subject, :text)
      #   .for(:create, params: {email: params}).on(:email)
      #
      #   should_not permit(:to)
      #   .for(:create, params: {email: params}).on(:email)
      # end
    end
  end
end
