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

  describe 'tags' do
    it 'limits the number of tags to 5' do
      bookmark = build(:bookmark)
      bookmark.tag_list = "tag1, tag2, tag3, tag4, tag5"
      expect(bookmark).to be_valid
      bookmark.tag_list = "tag1, tag2, tag3, tag4, tag5, tag6"
      expect(bookmark).not_to be_valid
      expect(bookmark.errors.messages).to include :tag_list
      expect(bookmark.errors.messages[:tag_list]).to eq [I18n.t("activerecord.errors.models.bookmark.attributes.tag_list.too_many")]
    end
  end

  describe 'update_tag_search' do
    it 'updates the attribute tag_search automatically based on used tags' do
      bookmark = build(:bookmark, tag_list: 'rails, wife')
      expect(bookmark.tag_search).to be_nil
      bookmark.save
      expect(bookmark.tag_search).to eq 'rails wife'
    end
  end

  describe 'search' do
    before(:each) do
      @rails = create(:bookmark, title: 'I love rails', description: 'Rails is the best framework, ever', tag_list: 'rails')
      @wife = create(:bookmark, title: 'I love my wife', description: 'If I would have a wife, she would me great, specially if she loves rails', tag_list: 'wife sport')
      @kayak = create(:bookmark, title: 'I love my kayak', description: 'Kayaking is such a relaxing sport', tag_list: 'water sport')
    end

    it 'finds by title' do
      expect(Bookmark.search('kayak')).to match_array [@kayak]
      expect(Bookmark.search('love')).to match_array [@rails, @wife, @kayak]
      expect(Bookmark.search('love my')).to match_array [@wife, @kayak]
    end

    it 'finds by description' do
      expect(Bookmark.search('relaxing')).to match_array [@kayak]
    end

    it 'finds by tags' do
      expect(Bookmark.search('water')).to match_array [@kayak]
      expect(Bookmark.search('sport')).to match_array [@wife, @kayak]
    end

    it 'orders results by weight tag -> title -> description' do
      expect(Bookmark.search("rails")).to eq [@rails, @wife]
    end
  end
end
