class ToolsController < ApplicationController
  before_action :authenticate_user!

  def index

  end

  def bookmarklet
    ahoy.track "tools-bookmarket", nil
    session.delete(:upgrade_bookmarklet)
  end

  # Show import page
  def import
    ahoy.track "tools-import", nil
  end

  # Called when user submit file to import
  def import_file
    input_file = params[:delicious]

    # Check that a file is uploaded
    unless input_file.present?
      @errors = I18n.t("tools.import.upload.errors.no_file")
      ahoy.track "tools-import_file", status: "error", error: @errors
      return render :import
    end

    # Check that the file type is correct
    unless input_file.content_type == 'text/html'
      @errors = I18n.t("tools.import.upload.errors.wrong_file_type", url: import_tool_path).html_safe
      ahoy.track "tools-import_file", status: "error", error: @errors
      return render :import
    end

    # Save the temporary file
    file_path = FileService.save_delicious_files(input_file, current_user.id)

    # Launch import job
    DeliciousImporterJob.perform_later(current_user, file_path)

    ahoy.track "tools-import_file", status: "success"

    # Confirm user that the bookmark will be imported
    redirect_to imported_tool_path
  end

  # File as been uploaded
  def imported
    ahoy.track "tools-imported", nil
  end
end
