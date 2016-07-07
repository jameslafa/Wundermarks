class UserProfilesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  after_action :verify_authorized, except: [:show]

  def show
    # If there is no id specified, we shot the current_user's profile
    if params[:id]
      @profile = UserProfile.find(params[:id])
    else
      @profile = get_current_user_profile
    end
  end

  def edit
    @profile = get_current_user_profile
    authorize @profile
  end

  def update
    @profile = get_current_user_profile
    authorize @profile

    respond_to do |format|
      if @profile.update(user_profile_params)
        format.html { redirect_to current_user_profile_path }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def get_current_user_profile
    UserProfile.find_by(user_id: current_user.try(:id))
  end

  def user_profile_params
    params.require(:user_profile).permit(:name, :introduction)
  end
end
