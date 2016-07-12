class HomeController < ApplicationController
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = Bookmark.tagged_with(@q).order(created_at: :desc)
    else
      @bookmarks = Bookmark.order(created_at: :desc)
    end
  end

  def tools
  end
end
