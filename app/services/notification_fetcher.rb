class NotificationFetcher
  class << self
    # Returns the number of unread user notifications
    # The limit_value == 11 is used because we display 10+ if there is more
    def unread_user_notifications_count(user, limit_value = 11)
      user.notifications.unread.limit(limit_value).count
    end

    # Returns the list of user_notifications
    def user_notifications(user, limit_value = 10)
      user.notifications.order(id: :desc).limit(limit_value)
    end

    # Mark every user notifications as read
    def mark_all_user_notifications_as_read(user)
      # update_all is a direct SQL request. It does no go through callbacks
      user.notifications.unread.update_all(read: true, read_at: Time.now)
    end
  end
end
