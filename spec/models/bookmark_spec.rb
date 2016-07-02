require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { is_expected.to belong_to :user }

  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :user }

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
