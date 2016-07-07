require "rails_helper"

RSpec.describe HomeController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/").to route_to("home#index")
    end

    it "routes to #tools" do
      expect(:get => "/tools").to route_to("home#tools")
    end
  end
end
