class BookmarkLikesController < ApplicationController
  before_action :authenticate_user!

  def create
    bookmark = Bookmark.find(params[:bookmark_id])
    ahoy.track "bookmark_likes-create", {current_user: current_user.id, bookmark_id: bookmark.id }

    bookmark = BookmarkService.like(bookmark.id, current_user.id)

    respond_to do |format|
      format.html { redirect_to bookmark_path(id: bookmark.id) }

      format.js do
        @bookmark = bookmark
        render :like
      end
    end
  end

  def destroy
    bookmark = Bookmark.find(params[:bookmark_id])
    ahoy.track "bookmark_likes-destroy", {current_user: current_user.id, bookmark_id: bookmark.id }

    bookmark = BookmarkService.unlike(bookmark.id, current_user.id)

    respond_to do |format|
      format.html { redirect_to bookmark_path(id: bookmark.id) }

      format.js do
        @bookmark = bookmark
        render :like
      end
    end
  end
end
