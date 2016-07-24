require 'rails_helper'

RSpec.describe BookmarkTracking, type: :model do
  it { is_expected.to belong_to :bookmark }

  it { is_expected.to validate_presence_of :bookmark }
  it { is_expected.to validate_presence_of :source }

  it { is_expected.to define_enum_for(:source).with({wundermarks: 1, facebook: 2, twitter: 3}) }

  let(:bookmark) { create(:bookmark) }

  describe 'track_click' do
    context 'when no tracking exists for this source' do
      it 'creates a new counter' do
        # Facebook
        expect{
          BookmarkTracking.track_click(bookmark, "facebook")
        }.to change(BookmarkTracking, :count).by(1)

        last_bookmark_tracking = BookmarkTracking.last
        expect(last_bookmark_tracking.bookmark).to eq bookmark
        expect(last_bookmark_tracking.source).to eq "facebook"
        expect(last_bookmark_tracking.count).to eq 1

        # Twitter
        expect{
          BookmarkTracking.track_click(bookmark, "twitter")
        }.to change(BookmarkTracking, :count).by(1)

        last_bookmark_tracking = BookmarkTracking.last
        expect(last_bookmark_tracking.bookmark).to eq bookmark
        expect(last_bookmark_tracking.source).to eq "twitter"
        expect(last_bookmark_tracking.count).to eq 1
      end
    end

    context 'when a tracking already exists for this source' do
      let!(:bookmark_tracking_facebook) { create(:bookmark_tracking_facebook, bookmark: bookmark, count: 12) }
      let!(:bookmark_tracking_twitter) { create(:bookmark_tracking_twitter, bookmark: bookmark, count: 12) }

      it 'increments the existing counter' do
        # Facebook
        expect{
          BookmarkTracking.track_click(bookmark, "facebook")
        }.not_to change(BookmarkTracking, :count)

        bookmark_tracking_facebook.reload
        expect(bookmark_tracking_facebook.count).to eq 13

        # Twitter
        expect{
          BookmarkTracking.track_click(bookmark, "twitter")
        }.not_to change(BookmarkTracking, :count)

        bookmark_tracking_twitter.reload
        expect(bookmark_tracking_twitter.count).to eq 13
      end
    end

    context 'when source does not exist' do
      it 'creates/increment a new counter with wundermarks as source' do
        BookmarkTracking.track_click(bookmark, nil)
        last_bookmark_tracking = BookmarkTracking.last
        expect(last_bookmark_tracking.source).to eq 'wundermarks'
        expect(last_bookmark_tracking.count).to eq 1

        BookmarkTracking.track_click(bookmark, 'unknown')
        last_bookmark_tracking = BookmarkTracking.last
        expect(last_bookmark_tracking.source).to eq 'wundermarks'
        expect(last_bookmark_tracking.count).to eq 2
      end
    end
  end
end
