class HelpController < ApplicationController
  def getting_started
    ahoy.track "help-getting_started", {source: params[:source]}
  end
end
