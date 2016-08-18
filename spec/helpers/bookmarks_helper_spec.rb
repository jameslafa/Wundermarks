require 'rails_helper'
include ApplicationHelper
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

  describe 'base_twitter_url' do
    it 'returns the bookmark permalinks with some tracking query parameter for twitter' do
      bookmark = build_stubbed(:bookmark)
      permalink = bookmark_shortlink_url(bookmark)
      base_url = base_twitter_url(bookmark)
      expect(base_url).to eq "#{permalink}?utm_medium=twitter&redirect=1"
      expect(base_url).to start_with "http://test.host"
    end
  end

  describe 'base_facebook_url' do
    it 'returns the bookmark permalinks with some tracking query parameter for facebook' do
      bookmark = build_stubbed(:bookmark)
      permalink = bookmark_shortlink_url(bookmark)
      base_url = base_facebook_url(bookmark)
      expect(base_url).to eq "#{permalink}?utm_medium=facebook&redirect=1"
      expect(base_url).to start_with "http://test.host"
    end
  end

  describe 'share_twitter_popup_url' do
    it 'returns the url to share a bookmark via twitter popup' do
      bookmark = build_stubbed(:bookmark, tag_list: 'tag1, tag2')
      base_url = base_twitter_url(bookmark)
      url_params = URI.encode_www_form([['via', 'wundermarks'],['text', bookmark.title], ['hashtags', 'tag1,tag2'], ['url', base_url]])
      expect(share_twitter_popup_url(bookmark)).to eq "https://twitter.com/intent/tweet?#{url_params}"
    end
  end

  describe 'share_facebook_popup_url' do
    it 'returns the url to share a bookmark via facebook popup' do
      bookmark = build_stubbed(:bookmark, tag_list: 'tag1, tag2')
      base_url = base_facebook_url(bookmark)
      expect(share_facebook_popup_url(bookmark)).to eq "https://www.facebook.com/dialog/share?app_id=#{Settings.facebook.app_id}&display=popup&href=#{ERB::Util.url_encode(base_url)}&redirect_uri=#{ERB::Util.url_encode(bookmark_permalink(bookmark, true))}&hashtag=%23wundermarks"
    end
  end

  describe 'bookmark_list_date' do
    context 'when the date is today' do
      it 'returns today' do
        expect(bookmark_list_date(Time.now.to_date)).to eq "Today"
      end
    end

    context 'when the date is yesterday' do
      it 'returns yesterday' do
        expect(bookmark_list_date(1.day.ago.to_date)).to eq "Yesterday"
      end
    end

    context 'when the date is less than 7 days old' do
      it 'returns the name of the day' do
        today = Date.new(2016,8,17) # Wednesday
        Timecop.freeze(today)
        date = today - 2.days
        expect(bookmark_list_date(date)).to eq "Last Monday"
        Timecop.return
      end
    end

    context 'when the date is 7 days old or more' do
      it 'returns the date of the day without the year' do
        date = 10.days.ago.to_date
        expect(bookmark_list_date(date)).to eq I18n.l(date, format: :long_no_year)
      end
    end

    context 'when the date more than a year old' do
      it 'returns the date of the day with the year' do
        date = 400.days.ago.to_date
        expect(bookmark_list_date(date)).to eq I18n.l(date, format: :long)
      end
    end
  end

  describe 'bookmark_time_ago' do
    it 'returns a short time distance' do
      expect(bookmark_time_ago(7.seconds.ago)).to eq "7s"
      expect(bookmark_time_ago(63.seconds.ago)).to eq "1m"
      expect(bookmark_time_ago(119.seconds.ago)).to eq "1m"
      expect(bookmark_time_ago(320.seconds.ago)).to eq "5m"
      expect(bookmark_time_ago(65.minutes.ago)).to eq "1h"
      expect(bookmark_time_ago(118.minutes.ago)).to eq "1h"
      expect(bookmark_time_ago(250.minutes.ago)).to eq "4h"
      expect(bookmark_time_ago(38.hours.ago)).to eq I18n.l(1.day.ago.to_date, format: :short)
    end
  end
end
