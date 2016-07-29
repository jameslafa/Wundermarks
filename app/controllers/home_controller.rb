class HomeController < ApplicationController
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = policy_scope(Bookmark).search(@q)
      ahoy.track "home-index", {q: @q}
    else
      @bookmarks = policy_scope(Bookmark).order(created_at: :desc)
      ahoy.track "home-index", nil unless request.headers["No-Tracking"].present?
    end
  end

  def tools
    ahoy.track "home-tools", nil
    session.delete(:upgrade_bookmarklet)
  end
end
