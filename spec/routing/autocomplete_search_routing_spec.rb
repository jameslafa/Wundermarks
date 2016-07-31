require "rails_helper"

RSpec.describe AutocompleteSearchController, type: :routing do
  describe "routing" do
    it "routes to #tags" do
      expect(:get => "/autocomplete_search/tags.json").to route_to("autocomplete_search#tags", format: 'json')
    end

    it "routes to #username_available" do
      expect(:get => "/autocomplete_search/username_available.json").to route_to("autocomplete_search#username_available", format: 'json')
    end
  end
end
