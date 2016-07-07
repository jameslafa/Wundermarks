require "rails_helper"

RSpec.describe UserProfilesController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(:get => "/profile/1").to route_to("user_profiles#show", :id => "1")
      expect(:get => "/profile").to route_to("user_profiles#show")
    end

    it "routes to #edit" do
      expect(:get => "/profile/edit").to route_to("user_profiles#edit")
    end

    it "routes to #update via PUT" do
      expect(:put => "/profile").to route_to("user_profiles#update")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/profile").to route_to("user_profiles#update")
    end
  end
end
