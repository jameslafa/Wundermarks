class Admin::AdminController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"

  # require the user to be an admin
  def authenticate_admin!
    redirect_to new_user_session_path unless current_user && current_user.admin?
  end
end
