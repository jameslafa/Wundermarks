class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Get list of notifications.
    # <trick> to_a put it to an array. Thanks to this,
    # NotificationFetcher.mark_all_user_notifications_as_read does not update
    # the read status before we display it in the view. It avoid us using
    # a background job to make the call asynchronise </trick>
    @notifications = NotificationFetcher.user_notifications(current_user).to_a
    unread_count = @notifications.select {|n| n.read == false}.count

    # Mark all notification as read
    NotificationFetcher.mark_all_user_notifications_as_read(current_user)

    ahoy.track "notifications-index", {user_id: current_user.id, unread_count: unread_count}
  end
end
