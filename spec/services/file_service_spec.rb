require 'rails_helper'
require 'fileutils'

RSpec.describe FileService, type: :service do
  describe "ensure_existence_upload_directory" do
    let(:upload_directory) { Rails.root.join('tmp', 'uploads') }

    context "when /tmp/upload does not exist" do
      it "creates the /tmp/upload directory" do
        FileUtils.rmdir(upload_directory)
        FileService.ensure_existence_upload_directory
        expect(File.directory?(upload_directory)).to be true
      end
    end

    it "returns the upload directory path" do
      expect(FileService.ensure_existence_upload_directory).to eq upload_directory
    end
  end

  describe "save_delicious_files" do
    let(:file) { fixture_file_upload("files/delicious_export.html", 'text/html') }

    it "saves the file in the temporary folder"
    it "names the temporary file correctly"
    it "saves the content of the file given as a parameter"
  end
end
