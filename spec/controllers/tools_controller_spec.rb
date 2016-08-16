require 'rails_helper'

RSpec.describe ToolsController, type: :controller do
  include Helpers

  let(:user_profile) { create(:user_profile) }
  let(:user) { user_profile.user}

  context 'when the user is not signed in' do
    describe "GET #bookmarklet" do
      it "redirects to new_user_session_path" do
        get :bookmarklet
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #import" do
      it "redirects to new_user_session_path" do
        get :import
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "POST #import_file" do
      it "redirects to new_user_session_path" do
        post :import
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "GET #imported" do
      it "redirects to new_user_session_path" do
        get :imported
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  context 'when the user is signed in' do
    before(:each) { sign_in_user(user) }

    describe "GET #bookmarklet" do
      it "removes :upgrade_bookmarklet from the session" do
        session[:upgrade_bookmarklet] = true
        get :bookmarklet
        expect(session[:upgrade_bookmarklet]).to be nil
      end
    end

    describe "POST #import_file" do
      context "when uploaded file is an HTML file" do
        let(:file) { fixture_file_upload("files/delicious_export.html", 'text/html') }

        it "saves the file in a temporary file" do
          expect(FileService).to receive(:save_delicious_files).with(file, subject.current_user.id)
          post :import_file, delicious: file
        end

        it "enqueues a DeliciousImporterJob" do
          file_path = "/tmp/file.html"
          allow(FileService).to receive(:save_delicious_files).and_return(file_path)

          expect {
            post :import_file, delicious: file
          }.to have_enqueued_job(DeliciousImporterJob).with { |args|
            expect(args).to eq([subject.current_user, file_path])
          }
        end

        it "redirect to the confirmation page" do
          post :import_file, delicious: file
          expect(response).to redirect_to imported_tool_path
        end

      end

      context "when uploaded file is NOT an HTML file" do
        let(:file) { fixture_file_upload("files/delicious_export_wrong_type.txt", 'text/plain') }
        before(:each) { post :import_file, delicious: file }

        it "renders :import template" do
          expect(response).to render_template :import
        end

        it "assigns @errors with an error message" do
          expect(assigns(:errors)).to eq I18n.t("tools.import.upload.errors.wrong_file_type", url: import_tool_path)
        end
      end

      context "when no file is uploaded" do
        before(:each) { post :import_file }

        it "renders :import template" do
          expect(response).to render_template :import
        end

        it "assigns @errors with an error message" do
          expect(assigns(:errors)).to eq I18n.t("tools.import.upload.errors.no_file")
        end
      end
    end
  end
end
