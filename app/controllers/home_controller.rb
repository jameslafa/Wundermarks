class HomeController < ApplicationController
  def index
    return redirect_to feed_path if current_user and params[:no_redirect].blank?

    @user = User.new
    @user.build_user_profile
    render :index, layout: "homepage"
  end

  def tools
    ahoy.track "home-tools", nil
    session.delete(:upgrade_bookmarklet)
  end

  def logos
    render :logos, layout: "homepage"
  end
end
