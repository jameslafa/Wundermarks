require "rails_helper"

RSpec.describe BookmarkLikesController, type: :routing do
  describe "routing" do
    it "routes to #destroy" do
      expect(:delete => "/bookmark_likes/1").to route_to("bookmark_likes#destroy", bookmark_id: "1")
    end

    it "routes to #create via POST" do
      expect(:post => "/bookmark_likes/1").to route_to("bookmark_likes#create", bookmark_id: "1")
    end
  end
end
