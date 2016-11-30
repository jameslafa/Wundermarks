class RegistrationsController < Devise::RegistrationsController
  def create
    super
    SlackNotifierJob.perform_later("new_user_registration", @user) if @user.persisted?
    ahoy.track "registrations-create", {user_id: @user.id}
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, user_profile_attributes: [:name])
  end
end
