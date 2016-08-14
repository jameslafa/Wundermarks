class BookmarksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: [:index, :new, :create]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = Bookmark.belonging_to(current_user).search(@q).paginated(params[:page])
      ahoy.track "bookmarks-search", q: @q, results_count: @bookmarks.try(:count)
      flash.now[:notice] = I18n.t("bookmarks.index.search.search_all_wundermarks", count: @bookmarks.count, search_all_url: feed_path(q: @q))

    elsif params[:post_import].present? and @source = params[:post_import] and Bookmark.sources.keys.include?(@source)
      @bookmarks = Bookmark.belonging_to(current_user).where(source: Bookmark.sources[@source]).paginated(params[:page]).last_first
      ahoy.track "bookmarks-post_import", source: @source, count: @bookmarks.count

    else
      @bookmarks = Bookmark.belonging_to(current_user).paginated(params[:page]).last_first
      ahoy.track "bookmarks-index", nil
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    authorize @bookmark

    # Track link
    BookmarkTracking.track_click(@bookmark, params[:utm_medium]) unless @bookmark.user == current_user

    return redirect_to @bookmark.url if params["redirect"].present? && params["redirect"].to_bool

    # Track action
    ahoy.track "bookmarks-show", {id: @bookmark.id}
  end

  # GET /bookmarks/new
  def new
    @bookmark = Bookmark.new(bookmarklet_params)
    @bookmark.title = @bookmark.title.truncate(Bookmark::MAX_TITLE_LENGTH) if @bookmark.title.present?
    @bookmark.description = @bookmark.description.truncate(Bookmark::MAX_DESCRIPTION_LENGTH) if @bookmark.description.present?

    respond_to do |format|
      if params[:layout] == 'popup'
        @layout = 'popup'

        # Check bookmarklet used version and see if the user need to update it
        bookmarklet_version = params[:v].to_i
        upgrade_bookmarklet = Settings.bookmarklet.current_version.to_i > bookmarklet_version.to_i
        session[:upgrade_bookmarklet] = upgrade_bookmarklet

        ahoy.track "bookmarks-new", {id: @bookmark.id, layout: 'popup', bm_v: bookmarklet_version, bm_updated: !upgrade_bookmarklet}
        format.html { render :new, layout: "popup" }
      else
        ahoy.track "bookmarks-show", {id: @bookmark.id, layout: 'web'}
        format.html { render :new }
      end
    end
  end

  # GET /bookmarks/1/edit
  def edit
    authorize @bookmark
    ahoy.track "bookmarks-edit", {id: @bookmark.id}
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.user = current_user

    respond_to do |format|
      if @bookmark.save
        # Add a notification into slack
        SlackNotifierJob.perform_later("new_bookmark", @bookmark)
        ahoy.track "bookmarks-create", {id: @bookmark.id}
        format.html { redirect_to bookmark_path(@bookmark) }
        format.json { render :show, status: :created, location: @bookmark }
      else
        format.html { render :new }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookmarks/1
  # PATCH/PUT /bookmarks/1.json
  def update
    authorize @bookmark
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        ahoy.track "bookmarks-update", {id: @bookmark.id}
        format.html { redirect_to bookmark_path(@bookmark) }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    authorize @bookmark
    bookmark_id = @bookmark.id
    @bookmark.destroy
    ahoy.track "bookmarks-destroy", {id: bookmark_id}
    respond_to do |format|
      format.html { redirect_to bookmarks_url, notice: 'Bookmark was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bookmark_params
    params.require(:bookmark).permit(:title, :description, :url, :tag_list, :privacy)
  end

  def bookmarklet_params
    params.permit(:title, :description, :url)
  end

  # Handle unauthorized access
  def user_not_authorized(exception)
    # I don't see any cases where the user could access to the bookmark content
    # but we are never too careful :-)
    @bookmark = nil

    # Generate the flash error message
    policy_name = exception.policy.class.to_s.underscore
    error_message = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    respond_to do |format|
      format.html { redirect_to bookmarks_path, alert: error_message }
      format.json { render json: {error: error_message}, status: :forbidden }
    end
  end
end
