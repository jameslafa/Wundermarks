class HomeController < ApplicationController
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = Bookmark.tagged_with(@q).order(created_at: :desc)
      ahoy.track "home-index", {q: @q}
    else
      @bookmarks = Bookmark.order(created_at: :desc)
      ahoy.track "home-index", nil
    end
  end

  def tools
    ahoy.track "home-tools", nil
  end
end
