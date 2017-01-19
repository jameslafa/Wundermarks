class Notifier
  class << self

    # Create a notification when a user like a bookmark
    def bookmark_like(bookmark, liker)
      Notification.create(recipient: bookmark.user, sender: liker, emitter: bookmark, activity: "bookmark_like")
    end

    # Create a notification when a user copy a bookmark
    def bookmark_copy(bookmark, copier)
      Notification.create(recipient: bookmark.user, sender: copier, emitter: bookmark, activity: "bookmark_copy")
    end

    # Create a notification when a user follow another user
    def user_follow(followed, follower)
      Notification.create(recipient: followed, sender: follower, emitter: followed, activity: "user_follow")
    end
  end
end
