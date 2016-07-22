class AutocompleteSearchController < ApplicationController
  before_action :authenticate_user!

  def tags
    results = []

    if @q = params[:q]
      if @q.size > 1
        results = ActsAsTaggableOn::Tag
          .where("name LIKE :search", search: "#{@q}%")
          .order(taggings_count: :desc)
          .limit(5)
          .pluck(:name)
      end
    end

    render json: results
  end
end
