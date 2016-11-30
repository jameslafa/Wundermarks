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

  # Return a string with city and country if informations are available
  # in user's profile
  def user_profile_place(user_profile)
    if user_profile.city.present? && user_profile.country.present?
      "#{user_profile.city}, #{get_country_name_from_code(user_profile.country)}"
    elsif user_profile.city.present? && user_profile.country.blank?
      user_profile.city
    elsif user_profile.city.blank? && user_profile.country.present?
      get_country_name_from_code(user_profile.country)
    end
  end

  # Get the translated country name from a country code
  def get_country_name_from_code(country_code)
    if country_code.present?
      country = ISO3166::Country[country_code]
      country.translations[I18n.locale.to_s] || country.name
    end
  end

  # Get the twitter profile page link from twitter username
  def twitter_link(username, link_options = nil)
    # default options
    link_options ||= {target: '_blank', rel: 'nofollow'}

    if username.present?
      link_to "@#{username}", "https://twitter.com/#{username}", link_options
    end
  end

  # Get the github profile page link from github username
  def github_link(username, link_options = nil)
    # default options
    link_options ||= {target: '_blank', rel: 'nofollow'}

    if username.present?
      link_to "@#{username}", "https://github.com/#{username}", link_options
    end
  end
end
