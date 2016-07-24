require 'rails_helper'
include BookmarksHelper

RSpec.describe 'BookmarksHelper', :type => :helper do
  let(:bookmark) { create(:bookmark, created_at: DateTime.new(2001,2,3,4,5,6), title: 'Here is my title') }

  describe 'bookmark_permalink' do
    context 'with url=false' do
      it 'generates a permalink path containing the creation date and title' do
        expect(bookmark_permalink(bookmark)).to eq "/bookmarks/#{bookmark.id}/2001-02-03_here-is-my-title"
      end
    end
    context 'with url=true' do
      it 'generates a permalink url containing the creation date and title' do
        expect(bookmark_permalink(bookmark, true)).to eq "http://test.host/bookmarks/#{bookmark.id}/2001-02-03_here-is-my-title"
      end
    end
  end

  describe 'url_with_query_parameters' do
    it 'adds a list of query parameters to a url' do
      new_params = [['via', 'wundermarks'], ['url', 'https://twitter.com/share?source=lemonde']]
      expect(url_with_query_parameters('https://google.com', new_params)).to eq "https://google.com?via=wundermarks&url=#{ERB::Util.url_encode("https://twitter.com/share?source=lemonde")}"
    end
  end

  describe 'base_twitter_url' do
    it 'returns the bookmark permalinks with some tracking query parameter for twitter' do
      bookmark = build_stubbed(:bookmark)
      permalink = bookmark_permalink(bookmark, true)
      base_url = base_twitter_url(bookmark)
      expect(base_url).to eq "#{permalink}?utm_source=user_share&utm_medium=twitter&redirect=1"
      expect(base_url).to start_with "http://test.host"
    end
  end

  describe 'base_facebook_url' do
    it 'returns the bookmark permalinks with some tracking query parameter for facebook' do
      bookmark = build_stubbed(:bookmark)
      permalink = bookmark_permalink(bookmark, true)
      base_url = base_facebook_url(bookmark)
      expect(base_url).to eq "#{permalink}?utm_source=user_share&utm_medium=facebook&redirect=1"
      expect(base_url).to start_with "http://test.host"
    end
  end

  describe 'share_twitter_popup_url' do
    it 'returns the url to share a bookmark via twitter popup' do
      bookmark = build_stubbed(:bookmark, tag_list: 'tag1, tag2')
      base_url = base_twitter_url(bookmark)
      expect(share_twitter_popup_url(bookmark)).to eq "https://twitter.com/intent/tweet?via=wundermarks&hashtags=#{ERB::Util.url_encode('tag1,tag2')}&url=#{ERB::Util.url_encode(base_url)}"
    end
  end

  describe 'share_facebook_popup_url' do
    it 'returns the url to share a bookmark via facebook popup' do
      bookmark = build_stubbed(:bookmark, tag_list: 'tag1, tag2')
      base_url = base_facebook_url(bookmark)
      expect(share_facebook_popup_url(bookmark)).to eq "https://www.facebook.com/dialog/share?app_id=#{Settings.facebook.app_id}&display=popup&href=#{ERB::Util.url_encode(base_url)}&redirect_uri=#{ERB::Util.url_encode(bookmark_permalink(bookmark, true))}&hashtag=%23wundermarks"
    end
  end
end
