class UserProfilesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  after_action :verify_authorized, except: [:show, :index]

  def index
    @profiles = UserProfile.includes(user: :user_metadatum)
                            .where("users.id != #{current_user.id}")
                            .order("user_metadata.public_bookmarks_count DESC")
                            .paginate(page: params[:page])

    # TODO: Get following_ids only of users in the current page
    @following_ids =  current_user.following_ids.to_set
    ahoy.track "user_profiles-index", {current_user: current_user.id }
  end

  def show
    # If there is no id specified, we shot the current_user's profile
    if params[:id].present?
      # If an id is given, it could be the username or the id.
      # We check if it's a integer or a string to know
      if params[:id].is_integer?
        @profile = UserProfile.find(params[:id])
      else
        @profile = UserProfile.find_by!(username: params[:id])
      end
    else
      @profile = get_current_user_profile
    end

    # User's preferences
    @preferences = @profile.user.preferences

    # Check if the profile should stay private
    @public_profile = current_user.present? || @preferences.public_profile == true

    # Set no index meta_tag if necessary
    update_meta_tag('noindex', !@public_profile || !@preferences.search_engine_index)

    if @public_profile
      # Show all bookmark from the profile's user
      if current_user.try(:id) == @profile.user.id
        @bookmarks = Bookmark.where(user_id: @profile.user.id).paginate(page: params[:page]).last_first
      else
        @bookmarks = policy_scope(Bookmark).where(user_id: @profile.user.id).paginate(page: params[:page]).last_first
      end

      # Is current_user following this profile
      if current_user && current_user.id != params[:id]
        @following = current_user.following?(@profile.user)
      end

      update_meta_tag('title', "#{@profile.name} (@#{@profile.username})")
      update_meta_tag('description', @profile.introduction) if @profile.introduction.present?
    end

    ahoy.track "user_profiles-show", {id: @profile.id, current_user: (current_user.try(:id) == @profile.user.id) }
  end

  def edit
    @profile = get_current_user_profile
    ahoy.track "user_profiles-edit", {id: @profile.id}
    authorize @profile
  end

  def update
    @profile = get_current_user_profile
    authorize @profile

    respond_to do |format|
      if @profile.update(user_profile_params)
        ahoy.track "user_profiles-update", {id: @profile.id}
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
    params.require(:user_profile).permit(:name, :introduction, :username,
    :country, :city, :website, :birthday, :twitter_username, :github_username, :avatar, :avatar_cache)
  end
end
