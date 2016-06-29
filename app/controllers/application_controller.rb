class ApplicationController < ActionController::Base
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Rescue from Pundit NotAuthorizedError. It should be defined in the
  # resource's controller but if it's not, we handle it here.
  # In the resource's controller, just override user_not_authorized.
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Default method to handle Pundit user_not_authorized error. Redifine this
  # method in your resource's controller.
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end
end
