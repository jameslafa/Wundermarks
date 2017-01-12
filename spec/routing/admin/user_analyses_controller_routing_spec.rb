require "rails_helper"

RSpec.describe Admin::UserAnalysesController, type: :routing do
  describe "routing" do
    it "routes to #last_connections" do
      expect(:get => "/admin/user_analyses/last_connections").to route_to("admin/user_analyses#last_connections")
    end

    it "routes to #use_bookmarklet" do
      expect(:get => "/admin/user_analyses/use_bookmarklet").to route_to("admin/user_analyses#use_bookmarklet")
    end

    it "routes to #user_activity" do
      expect(:get => "/admin/user_analyses/user_activity").to route_to("admin/user_analyses#user_activity")
    end
  end
end
