module UserProfilesHelper
  def user_profile_permalink(user_profile, full_url=false)
    return unless user_profile
    # If the profile has a username, we use it as an id, if not, we use the real id
    user_profile_id = user_profile.username || user_profile.id
    
    if full_url
      user_profile_url(id: user_profile_id)
    else
      user_profile_path(id: user_profile_id)
    end
  end
end
