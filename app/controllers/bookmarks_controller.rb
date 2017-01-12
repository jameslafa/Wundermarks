class BookmarksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: [:index, :new, :create]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = Bookmark.belonging_to(current_user).search(@q).paginate(page: params[:page])
      ahoy.track "bookmarks-search", q: @q, results_count: @bookmarks.try(:count)
      flash.now[:notice] = I18n.t("bookmarks.index.search.search_all_wundermarks", count: @bookmarks.count, search_friends_url: feed_path(q: @q), search_all_url: feed_path(q: @q, filter: 'everyone'))

    elsif params[:post_import].present? and @source = params[:post_import] and Bookmark.sources.keys.include?(@source)
      @bookmarks = Bookmark.belonging_to(current_user).where(source: Bookmark.sources[@source]).paginate(page: params[:page]).last_first
      ahoy.track "bookmarks-post_import", source: @source, count: @bookmarks.count

    else
      @bookmarks = Bookmark.belonging_to(current_user).paginate(page: params[:page]).last_first
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

    update_meta_tag('title', @bookmark.title) if @bookmark.title.present?
    update_meta_tag('description', @bookmark.description) if @bookmark.description.present?

    # Track action
    ahoy.track "bookmarks-show", {id: @bookmark.id}
  end

  # GET /bookmarks/new
  def new
    @bookmark = Bookmark.new

    # If an :id is present in the parameters, we get attributes from this record
    if params.has_key?(:id) && params[:id].present?
      @origin_bookmark = Bookmark.find(params[:id])
      authorize @origin_bookmark, :show?
      @bookmark.attributes = @origin_bookmark.slice(:title, :description, :url, :tag_list)
      @bookmark.copy_from_bookmark_id = params[:id]

      # If not, we get attributes from bookmarklet_params
      # If there is no bookmarklet_params, it will simple keep the new bookmark empty
    else
      @bookmark.attributes = bookmarklet_params
      @bookmark.title = @bookmark.title.truncate(Bookmark::MAX_TITLE_LENGTH) if @bookmark.title.present?
      @bookmark.description = @bookmark.description.truncate(Bookmark::MAX_DESCRIPTION_LENGTH) if @bookmark.description.present?
    end


    if @bookmark.url.present?

      # If the user is bookmarking the bookmarklet installation page, he confirms the installation is succesful
      if uri = URI(@bookmark.url) and uri.host.end_with?(Rails.application.routes.default_url_options[:host]) && uri.path == bookmarklet_tool_path
        return redirect_to bookmarklet_successfully_installed_path(v: params[:v])
      end
      # Check if the current user already bookmarked this url
      if @existing_bookmark = check_bookmark_does_not_exist(@bookmark.url)
        flash.now.alert = "#{I18n.t("errors.bookmarks.already_exists")}. #{view_context.link_to(I18n.t("errors.bookmarks.see_existing_bookmark"), bookmark_path(@existing_bookmark.id), class: 'alert-link')}.".html_safe
      end
    end

    respond_to do |format|
      if params[:layout] == 'popup'
        @layout = 'popup'

        # Check bookmarklet used version and see if the user need to update it
        bookmarklet_version = params[:v].to_i
        upgrade_bookmarklet = Settings.bookmarklet.current_version.to_i > bookmarklet_version.to_i
        session[:upgrade_bookmarklet] = upgrade_bookmarklet

        ahoy.track "bookmarks-new", {layout: 'popup', bm_v: bookmarklet_version, bm_updated: !upgrade_bookmarklet, duplicate_bookmark_warning: @existing_bookmark.present?}
        format.html { render :new, layout: "popup" }
      else
        if @bookmark.copy_from_bookmark_id
          ahoy.track "bookmarks-new", {layout: 'web', copy_from_bookmark_id: @bookmark.copy_from_bookmark_id, duplicate_bookmark_warning: @existing_bookmark.present?}
        else
          ahoy.track "bookmarks-new", {layout: 'web'}
        end
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
        # Update user's metadata
        UserMetadataUpdater.update_bookmarks_count(@bookmark)

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

    # Update user's metadata
    UserMetadataUpdater.update_bookmarks_count(@bookmark)

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
    params.require(:bookmark).permit(:title, :description, :url, :tag_list, :privacy, :copy_from_bookmark_id)
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

  # Search if the bookmark already exist for the current user.
  # Return the bookmark if it does, if not, return nil
  def check_bookmark_does_not_exist(url)
    existing_bookmark = nil

    if url.present?
      existing_bookmark = Bookmark.find_by(user_id: current_user.id, url: url)
    end

    existing_bookmark
  end
end
