require "rails_helper"

RSpec.describe FeedController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/feed").to route_to("feed#index")
    end
  end
end
