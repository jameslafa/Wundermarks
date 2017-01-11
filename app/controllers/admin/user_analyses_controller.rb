class Admin::UserAnalysesController < Admin::AdminController

  def last_connections
    @user_data = []

    User.includes(:user_profile).each do |user|
      last_connection = Visit.where(user_id: user.id).pluck(:started_at).last

      @user_data << {
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        name: user.profile.name,
        username: user.profile.username,
        last_visit: last_connection
      }
    end

    @user_data.sort_by! { |u| -1 * u[:last_visit].to_i || 0 }
  end

  def use_bookmarklet
    @user_data = []

    User.includes(:user_profile).each do |user|
      events = Ahoy::Event.where(user_id: user.id, name: "bookmarks-new").where("properties->>'layout' = ?", 'popup').last(3)

      if events.size > 0
        bookmarklet_version = events.first.properties["bm_v"] || 0
        bookmarket_up_to_date = bookmarklet_version >= Settings.bookmarklet.current_version.to_i

        @user_data << {id: user.id, name: user.profile.name, email: user.email, has_bookmarket: true, bookmarklet_version: bookmarklet_version, bookmarket_up_to_date: bookmarket_up_to_date}
      else
        @user_data << {id: user.id, name: user.profile.name, email: user.email, has_bookmarket: false, bookmarklet_version: 0, bookmarket_up_to_date: false}
      end
    end

    @user_data.sort_by! { |u| u[:bookmarklet_version] }
  end
end
