class FeedController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = policy_scope(Bookmark).search(@q).paginated(params[:page])
      ahoy.track "feed-index", {q: @q}
    else
      @bookmarks = policy_scope(Bookmark).paginated(params[:page]).last_first
      ahoy.track "feed-index", nil
    end
  end
end
