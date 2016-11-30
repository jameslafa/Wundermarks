require "rails_helper"

RSpec.describe UserRelationshipsController, type: :routing do
  describe "routing" do
    it "routes to #destroy" do
      expect(:delete => "/user_relationships/1").to route_to("user_relationships#destroy", user_id: "1")
    end

    it "routes to #create via POST" do
      expect(:post => "/user_relationships/1").to route_to("user_relationships#create", user_id: "1")
    end
  end
end
