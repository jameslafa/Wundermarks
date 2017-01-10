class BookmarkLike < ActiveRecord::Base
  belongs_to :bookmark, counter_cache: true
  belongs_to :user
end
