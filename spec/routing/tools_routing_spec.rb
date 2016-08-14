require "rails_helper"

RSpec.describe ToolsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/tools").to route_to("tools#index")
    end

    it "routes to #bookmarklet" do
      expect(:get => "/tools/bookmarklet").to route_to("tools#bookmarklet")
    end

    it "routes to #import" do
      expect(:get => "/tools/import").to route_to("tools#import")
    end

    it "routes to #import_file" do
      expect(:post => "/tools/import").to route_to("tools#import_file")
    end

    it "routes to #imported" do
      expect(:get => "/tools/imported").to route_to("tools#imported")
    end
  end
end
