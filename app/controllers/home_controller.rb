class HomeController < ApplicationController
  def index
    @bookmarks = Bookmark.order(created_at: :desc)
  end
end
