class BookmarkTracking < ActiveRecord::Base
  belongs_to :bookmark

  validates_presence_of :bookmark, :source

  enum source: {wundermarks: 1, facebook: 2, twitter: 3}

  def self.track_click(bookmark, source)
    source = source.to_s
    source = 'wundermarks' unless self.sources.has_key? source.to_s

    tracking = BookmarkTracking.where(bookmark_id: bookmark.id, source: self.sources[source]).first_or_initialize
    tracking.increment(:count)
    tracking.save
  end
end
