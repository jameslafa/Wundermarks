require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { is_expected.to belong_to :user }

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :user }

  describe 'scopes' do
    describe 'belonging_to' do
      it 'scopes bookmark query to bookmarks belonging to a specified person' do
        users = create_list(:user, 2)
        first_user_bookmarks = create_list(:bookmark, 2, user: users.first)
        second_user_bookmarks = create_list(:bookmark, 2, user: users.second)
        expect(Bookmark.belonging_to(users.first)).to match_array first_user_bookmarks
      end
    end
  end

  describe 'tags_list' do
    it 'creates tags from a string separated with commas' do
      bookmark = build_stubbed(:bookmark, tag_list: 'tag-1, tag-2,tag-3')
      expect(bookmark.tag_list).to eq ['tag-1', 'tag-2', 'tag-3']
    end

    it 'saves tags downcased' do
      bookmark = build_stubbed(:bookmark, tag_list: 'Tag-1, TAG-2')
      expect(bookmark.tag_list).to eq ['tag-1', 'tag-2']
    end

    it 'saves tags parameterised' do
      bookmark = build_stubbed(:bookmark, tag_list: 'my tag 1, MyTag2')
      expect(bookmark.tag_list).to eq ['my-tag-1', 'mytag2']
    end
  end
end
