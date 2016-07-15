require "rails_helper"

RSpec.describe EmailsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(:get => "/emails/new").to route_to("emails#new")
      expect(:get => "/emails").to route_to("emails#new")
      expect(:get => "/contact").to route_to("emails#new")
    end

    it "routes to #create" do
      expect(:post => "/emails").to route_to("emails#create")
    end
  end
end
