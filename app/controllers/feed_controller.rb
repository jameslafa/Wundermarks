class FeedController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = policy_scope(Bookmark).search(@q)
      ahoy.track "feed-index", {q: @q}
    else
      @bookmarks = policy_scope(Bookmark).order(created_at: :desc)
      ahoy.track "feed-index", nil unless request.headers["No-Tracking"].present?
    end
  end
end
