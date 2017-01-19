require 'rails_helper'
include ApplicationHelper

RSpec.describe 'ApplicationHelper', :type => :helper do

  describe 'url_with_query_parameters' do
    it 'adds a list of query parameters to a url' do
      new_params = [['via', 'wundermarks'], ['url', 'https://twitter.com/share?source=lemonde']]
      expect(url_with_query_parameters('https://google.com', new_params)).to eq "https://google.com?via=wundermarks&url=#{ERB::Util.url_encode("https://twitter.com/share?source=lemonde")}"
    end
  end

  describe 'text_to_html' do
    it 'removes any unwanted tags' do
      bad_string = '<b>bold</b><strong>strong</strong><em>emphasys</em><i>italic</i><img src="http://google.fr/image.jpg"/><script>bad_thing();</script>'
      good_string = '<p><b>bold</b><strong>strong</strong><em>emphasys</em><i>italic</i>bad_thing();</p>'
      expect(text_to_html(bad_string)).to eq good_string
    end

    it 'adds html new lines' do
      string_with_new_line = "first_line\nnew_line"
      string_with_html_new_line = "<p>first_line\n<br />new_line</p>"
      expect(text_to_html(string_with_new_line)).to eq string_with_html_new_line
    end

    it 'transform urls to links with target: _blank and rel: nofollow' do
      string_with_url = "my webpage is https://wundermarks.com"
      string_with_link = '<p>my webpage is <a href="https://wundermarks.com" target="_blank" rel="nofollow">https://wundermarks.com</a></p>'
    end
  end

  describe 'notifications_count' do
    it 'returns the user notifications count as a string' do
      user = build_stubbed(:user)

      allow(NotificationFetcher).to receive(:unread_user_notifications_count).and_return(0)
      expect(notifications_count(user)).to eq ''

      allow(NotificationFetcher).to receive(:unread_user_notifications_count).and_return(4)
      expect(notifications_count(user)).to eq '4'

      allow(NotificationFetcher).to receive(:unread_user_notifications_count).and_return(11)
      expect(notifications_count(user)).to eq '10+'

      allow(NotificationFetcher).to receive(:unread_user_notifications_count).and_return(4)
      expect(notifications_count(nil)).to eq ''
    end
  end

end
