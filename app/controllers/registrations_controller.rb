class RegistrationsController < Devise::RegistrationsController
  
  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, user_profile_attributes: [:name])
  end
end
