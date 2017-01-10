class BookmarkService
  class << self
    def like(bookmark_id, user_id)
      bookmark = Bookmark.find_by(id: bookmark_id)
      if bookmark && User.exists?(user_id)
        unless bookmark.user_id == user_id
          unless bookmark.likes.find_by(user_id: user_id)
            bookmark.likes.create(user_id: user_id)
            bookmark.liked = true
          end
        end
      else
        raise ActiveRecord::RecordNotFound
      end

      bookmark
    end

    def unlike(bookmark_id, user_id)
      bookmark = Bookmark.find_by(id: bookmark_id)

      if bookmark && User.exists?(user_id)
        if bookmark.user_id != user_id
          if bookmark_like = bookmark.likes.find_by(user_id: user_id)
            bookmark.likes.destroy(bookmark_like)
            # We have to reload to update the counter cache when the association
            # is destroyed. Rails' bug?
            bookmark.likes.reload
            bookmark.liked = false
          end
        end
      else
        raise ActiveRecord::RecordNotFound
      end

      bookmark
    end

    def set_user_bookmark_likes(bookmarks, user_id)
      # Get list of bookmark ids
      bookmark_ids = bookmarks.collect { |b| b.id }

      # Get list of bookmark ids which where liked by the user
      liked_bookmark_ids = BookmarkLike.where(bookmark_id: bookmark_ids, user_id: user_id).pluck(:bookmark_id)

      # Set the liked status on each bookmark
      bookmarks.each do |b|
        b.liked = liked_bookmark_ids.include?(b.id)
      end

      bookmarks
    end
  end
end
