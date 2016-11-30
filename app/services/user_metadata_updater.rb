class UserMetadataUpdater
  class << self

    # Update counters concerning user_relationships
    # User by == 1 if 2 users create a new relationship : follower follows followed
    # User by == -1 if 2 users destroy a new relationship : follower unfollows followed
    def update_relationships_count(follower, followed, by = 1)
      if by > 0
        follower.metadata.increment!(:followings_count, by)
        followed.metadata.increment!(:followers_count, by)
      else
        follower.metadata.decrement!(:followings_count, -1 * by)
        followed.metadata.decrement!(:followers_count, -1 * by)
      end
    end

    def update_bookmarks_count(bookmark)
      if bookmark.persisted?
        bookmark.user.metadata.increment!(:bookmarks_count, 1)
        if bookmark.everyone?
          bookmark.user.metadata.increment!(:public_bookmarks_count, 1)
        end
      elsif bookmark.destroyed?
        bookmark.user.metadata.decrement!(:bookmarks_count, 1)
        if bookmark.everyone?
          bookmark.user.metadata.decrement!(:public_bookmarks_count, 1)
        end
      end
    end

    def reset_user_metadatum(user)
      return unless user.present?

      user.save if user.user_metadatum.blank?

      user.user_metadatum.followers_count = user.followers_by_type_count('User')
      user.user_metadatum.followings_count = user.following_by_type_count('User')
      user.user_metadatum.bookmarks_count = user.bookmarks.size
      user.user_metadatum.public_bookmarks_count = user.bookmarks.visible_to_everyone.size
      user.user_metadatum.save
    end
  end
end
