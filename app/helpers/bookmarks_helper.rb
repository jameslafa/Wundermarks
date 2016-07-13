module BookmarksHelper
  def bookmark_permalink(bookmark)
    bookmark_permalink_path(id: bookmark.id, title: "#{bookmark.created_at.to_date}_#{bookmark.title.parameterize}")
  end
end
