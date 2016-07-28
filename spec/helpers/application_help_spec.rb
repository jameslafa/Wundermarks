require 'rails_helper'
include ApplicationHelper

RSpec.describe 'ApplicationHelper', :type => :helper do

  describe 'url_with_query_parameters' do
    it 'adds a list of query parameters to a url' do
      new_params = [['via', 'wundermarks'], ['url', 'https://twitter.com/share?source=lemonde']]
      expect(url_with_query_parameters('https://google.com', new_params)).to eq "https://google.com?via=wundermarks&url=#{ERB::Util.url_encode("https://twitter.com/share?source=lemonde")}"
    end
  end

end
