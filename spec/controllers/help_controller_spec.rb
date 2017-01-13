require 'rails_helper'

RSpec.describe HelpController, type: :controller do

  describe "GET #getting_started" do
    it "tracks an ahoy event" do
      expect{
        get :getting_started, source: "feed_no_bookmark"
      }.to change(Ahoy::Event, :count).by(1)
      event = Ahoy::Event.last
      expect(event.name).to eq 'help-getting_started'
      expect(event.properties).to eq({"source" => "feed_no_bookmark"})
    end

    it "renders template :getting_started" do
      get :getting_started
      expect(response).to render_template :getting_started
    end
  end

end
