class PreferencesController < ApplicationController
  before_action :authenticate_user!

  def edit
    @preference = current_user.user_preference
    ahoy.track "user_preferences-edit", {user_id: current_user.id}
  end

  def update
    @preference = current_user.user_preference

    respond_to do |format|
      if @preference.update(preferences_params)
        ahoy.track "user_preferences-update", {user_id: current_user.id}
        format.html { redirect_to edit_preferences_path, notice: I18n.t('notices.user_preferences_updated') }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def preferences_params
    params.require(:user_preference).permit(:search_engine_index, :public_profile)
  end
end
