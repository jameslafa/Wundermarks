require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { is_expected.to belong_to :user }
  it { is_expected.to have_many(:bookmark_trackings).dependent(:destroy) }

  it { is_expected.to validate_uniqueness_of(:url).scoped_to(:user_id) }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :url }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_length_of(:title).is_at_most(80) }
  it { is_expected.to validate_length_of(:description).is_at_most(255) }

  it { is_expected.to define_enum_for(:privacy).with({everyone: 1, only_me: 2}) }
  it { is_expected.to define_enum_for(:source).with({wundermarks: 0, delicious: 1}) }

  describe 'scopes' do
    describe 'belonging_to' do
      it 'returns bookmarks belonging to a specified person' do
        users = create_list(:user, 2)
        first_user_bookmarks = create_list(:bookmark, 2, user: users.first)
        second_user_bookmarks = create_list(:bookmark, 2, user: users.second)
        expect(Bookmark.belonging_to(users.first)).to match_array first_user_bookmarks
      end
    end

    describe 'visible_to_everyone' do
      it 'returns bookmarks with privacy level to everyone' do
        user = create(:user)
        bookmarks_visible_to_everyone = create_list(:bookmark, 2, privacy: 1, user: user)
        bookmark_visible_to_only_me = create(:bookmark, privacy: 2, user: user)

        expect(Bookmark.visible_to_everyone).to match_array bookmarks_visible_to_everyone
      end
    end

    describe 'last_first' do
      it 'returns bookmarks ordered :desc' do
        user = create(:user)
        bookmarks = create_list(:bookmark, 3)
        expect(Bookmark.last_first).to eq bookmarks.reverse
      end
    end

    describe 'paginated' do
      it 'returns bookmarks paginated bookmarks' do
        user = create(:user)
        bookmarks = create_list(:bookmark, 28)
        expect(Bookmark.paginated("1").size).to eq 25
        expect(Bookmark.paginated("2").reload.size).to eq 3
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

  describe 'url_domain' do
    let(:bookmark) { create(:bookmark, url: 'http://google.com/search') }

    it 'returns the domain of the url' do
        expect(bookmark.url_domain).to eq 'google.com'
    end
  end

  describe 'sharing_statistics' do
    let(:bookmark) { create(:bookmark) }

    it 'returns a Hash with tracking count per source' do
      create(:bookmark_tracking_wundermarks, bookmark: bookmark, count: 12)
      create(:bookmark_tracking_facebook, bookmark: bookmark, count: 13)
      create(:bookmark_tracking_twitter, bookmark: bookmark, count: 14)

      expect(bookmark.sharing_statistics).to eq({
        "wundermarks" => 12,
        "facebook" => 13,
        "twitter" => 14,
        "total" => 39
      })
    end
  end

  describe 'source' do
    it 'is set to wundermarks per default' do
      bookmark = Bookmark.new(user_id: 1, title: 'title', url: 'https://url.com')
      expect(bookmark.source).to eq 'wundermarks'
    end
  end

  describe 'copy_from_bookmark_id' do
    it 'can be set only on creation and cannot be updated later' do
      bookmark = create(:bookmark, copy_from_bookmark_id: 50)
      expect(bookmark.copy_from_bookmark_id).to eq 50

      bookmark.copy_from_bookmark_id = 20
      bookmark.save

      expect(bookmark.errors.messages).to include :copy_from_bookmark_id
      expect(bookmark.errors.messages[:copy_from_bookmark_id]).to eq [I18n.t("activerecord.errors.models.bookmark.attributes.copy_from_bookmark_id.cannot_be_updated")]

      bookmark.reload
      expect(bookmark.copy_from_bookmark_id).to eq 50
    end
  end
end
