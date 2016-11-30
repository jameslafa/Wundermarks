class UserRelationshipsController < ApplicationController
  include UserProfilesHelper

  before_action :authenticate_user!

  def create
    other_user = User.find(params[:user_id])
    ahoy.track "user_relationships-create", {current_user: current_user.id, id: other_user.id }

    # Check if the user relationship already exists
    @following = current_user.following?(other_user)

    # If it does not exist, then we create it and we update user_metadatum
    # if it has been created successfully
    unless @following
      if current_user.follow(other_user)
        @following = true
        UserMetadataUpdater.update_relationships_count(current_user, other_user, 1)
      end
    end

    respond_to do |format|
      format.html { redirect_to user_profile_permalink(other_user.user_profile) }
      format.js do
        @user_id = other_user.id
        render :follow
      end
    end

  end

  def destroy
    other_user = User.find(params[:user_id])
    ahoy.track "user_relationships-destroy", {current_user: current_user.id, id: other_user.id }

    # Check if the user relationship already exists
    @following = current_user.following?(other_user)

    # If it does exist, then we delete it and we update user_metadatum
    # if it has been deleted successfully
    if @following
      if current_user.stop_following(other_user)
        @following = false
        UserMetadataUpdater.update_relationships_count(current_user, other_user, -1)
      end
    end

    respond_to do |format|
      format.html { redirect_to user_profile_permalink(other_user.user_profile) }
      format.js do
        @user_id = other_user.id
        render :follow
      end
    end
  end
end
