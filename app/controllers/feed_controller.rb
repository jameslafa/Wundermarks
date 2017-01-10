class FeedController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = bookmarks_users_scope.search(@q).paginate(page: params[:page])
      if @bookmarks.count > 0
        flash.now[:notice] = I18n.t("feed.index.search.search_all_wundermarks", count: @bookmarks.count, search_all_url: feed_path(q: @q, filter: 'everyone'))
      else
        flash.now[:notice] = I18n.t("feed.index.search.nothing_found_html")
      end
      ahoy.track "feed-search", q: @q, results_count: @bookmarks.try(:count)
    else
      @bookmarks = bookmarks_users_scope.paginate(page: params[:page]).last_first
      sliced_params = params.slice(:q, :filter)
      ahoy.track "feed-index", sliced_params.empty? ? nil : sliced_params
    end

    @bookmarks = BookmarkService.set_user_bookmark_likes(@bookmarks, current_user.id)
  end

  private

  def bookmarks_users_scope
    #TODO: This could be optimized in only one query instead of Followins -> Bookmarks
    if params[:filter] == "everyone"
      policy_scope(Bookmark)
    else
      users = current_user.all_following
      users << current_user
      policy_scope(Bookmark).where(user: users)
    end
  end
end
