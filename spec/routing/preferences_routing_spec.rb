require "rails_helper"

RSpec.describe PreferencesController, type: :routing do
  describe "routing" do
    it "routes to #edit" do
      expect(:get => "/preferences").to route_to("preferences#edit")
      expect(:get => "/preferences/edit").to route_to("preferences#edit")
    end

    it "routes to #update" do
      expect(:put => "/preferences").to route_to("preferences#update")
      expect(:patch => "/preferences").to route_to("preferences#update")
    end
  end
end
