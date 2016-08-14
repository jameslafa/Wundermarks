require 'fileutils'

class FileService

  class << self
    # Make sure the upload_directory exist and return the path
    def ensure_existence_upload_directory
      upload_directory_path = Rails.root.join('tmp', 'uploads')
      FileUtils.mkdir_p(upload_directory_path)
      upload_directory_path
    end

    # Save the delicious file of the user in the upload directory
    def save_delicious_files(input_file, user_id)
      upload_dir = FileService.ensure_existence_upload_directory
      file_path = File.join(upload_dir, "delicious_user-#{user_id}_#{Time.now.to_i}.html")
      File.open(file_path, 'wb') do |file|
        file.write(input_file.read)
      end
      file_path
    end
  end
end
