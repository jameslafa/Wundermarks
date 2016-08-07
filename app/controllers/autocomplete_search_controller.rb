class AutocompleteSearchController < ApplicationController
  before_action :authenticate_user!

  # Find tags maching the query for tag suggestion, only in tags used buy the user
  def tags
    @tags = []

    if @q = params[:q]
      if @q.size > 1
        @tags = current_user.bookmarks.tag_counts_on(:tags)
          .select([:name, :taggings_count])
          .where("name LIKE :search", search: "#{@q}%")
          .order(taggings_count: :desc)
          .limit(5)
          .pluck(:name)
      end
    end

    render json: @tags
  end

  # Control that the username is available for the current_user
  def username_available
    # To do so, we use the normal rails validation process on the
    # current_user profile.
    # After replacing the username with the one queried, we validate it
    # and check that the username is valid. If not, we return the error.
    user_profile = current_user.user_profile
    user_profile.username = params[:q]
    user_profile.validate

    if user_profile.errors[:username].present?
      valid = false
      message = "#{params[:q]} #{user_profile.errors[:username].to_sentence}"
    else
      valid = true
      message = I18n.t("user_profiles.form.username_available", username: user_profile.username)
    end

    render json: {valid: valid, message: message}
  end
end
