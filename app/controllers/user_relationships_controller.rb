class UserRelationshipsController < ApplicationController
  include UserProfilesHelper

  before_action :authenticate_user!

  def create
    other_user = User.find(params[:user_id])
    current_user.follow(other_user)

    ahoy.track "user_relationships-create", {current_user: current_user.id, id: other_user.id }

    redirect_to user_profile_permalink(other_user.user_profile)
  end

  def destroy
    other_user = User.find(params[:id])
    current_user.stop_following(other_user)

    ahoy.track "user_relationships-destroy", {current_user: current_user.id, id: other_user.id }

    redirect_to user_profile_permalink(other_user.user_profile)
  end
end
