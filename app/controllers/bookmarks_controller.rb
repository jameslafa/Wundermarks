class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: [:index, :show, :new, :create]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    if params[:q].present? and @q = params[:q]
      @bookmarks = Bookmark.belonging_to(current_user).tagged_with(@q).order(created_at: :desc)
    else
      @bookmarks = Bookmark.belonging_to(current_user).order(created_at: :desc)
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    @bookmark
  end

  # GET /bookmarks/new
  def new
    @bookmark = Bookmark.new(bookmarklet_params)

    respond_to do |format|
      if params[:layout] == 'popup'
        @layout = 'popup'
        format.html { render :new, layout: "popup" }
      else
        format.html { render :new }
      end
    end
  end

  # GET /bookmarks/1/edit
  def edit
    authorize @bookmark
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.user = current_user

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to bookmarks_path }
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
        format.html { redirect_to bookmarks_path }
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
    @bookmark.destroy
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
      params.require(:bookmark).permit(:title, :description, :url, :tag_list)
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
      flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

      # Redirect the user to his own bookmark list
      redirect_to(bookmarks_path)
    end
end
