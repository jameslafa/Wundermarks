class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Rescue from Pundit NotAuthorizedError. It should be defined in the
  # resource's controller but if it's not, we handle it here.
  # In the resource's controller, just override user_not_authorized.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # saves the location before loading each page so we can return to the
  # right page. If we're on a devise page, we don't want to store that as the
  # place to return to (for example, we don't want to return to the sign in page
  # after signing in), which is what the :unless prevents
  before_filter :store_current_location, :unless => :devise_controller?

  def after_sign_in_path_for(resource)
    # FYI: stored_location_for(:user) can be called only once, second time it returns nil
    stored_location = stored_location_for(:user)
    return stored_location if stored_location

    if resource.user_profile.username.present?
      feed_path
    else
      edit_current_user_profile_path
    end

  end

  private

  # Default method to handle Pundit user_not_authorized error. Redifine this
  # method in your resource's controller.
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end

  # override the devise helper to store the current location so we can
  # redirect to it after loggin in or out. This override makes signing in
  # and signing up work automatically.
  def store_current_location
    store_location_for(:user, request.url)
  end

  # override the devise method for where to go after signing out because theirs
  # always goes to the root path. Because devise uses a session variable and
  # the session is destroyed on log out, we need to use request.referrer
  # root_path is there as a backup
  def after_sign_out_path_for(resource)
    request.referrer || root_path
  end
end
