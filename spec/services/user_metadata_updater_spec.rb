RSpec.describe UserMetadataUpdater, type: :service do

  describe 'update_relationships_count' do
    let(:follower) { create(:user_with_metadatum, user_metadatum: follower_metadatum) }
    let(:followed) { create(:user_with_metadatum, user_metadatum: followed_metadatum) }

    context 'when by == 1' do
      let(:follower_metadatum) { create(:user_metadatum) }
      let(:followed_metadatum) { create(:user_metadatum) }

      it 'increase followers_count and followings_count' do
        UserMetadataUpdater.update_relationships_count(follower, followed, 1)
        expect(follower.metadata.followings_count).to eq 1
        expect(followed.metadata.followers_count).to eq 1
      end
    end

    context 'when by == -1' do
      let(:follower_metadatum) { create(:user_metadatum, followings_count: 2) }
      let(:followed_metadatum) { create(:user_metadatum, followers_count: 2) }

      it 'decrease followers_count and followings_count' do
        UserMetadataUpdater.update_relationships_count(follower, followed, -1)
        expect(follower.metadata.followings_count).to eq 1
        expect(followed.metadata.followers_count).to eq 1
      end
    end
  end

  describe 'update_bookmarks_count' do
    context 'when the bookmark is created' do
      let(:user) { create(:user_with_metadatum) }

      context 'and has visibility to everyone' do
        it 'increments bookmarks_count and public_bookmarks_count' do
          bookmark = create(:bookmark_visible_to_everyone, user: user)
          UserMetadataUpdater.update_bookmarks_count(bookmark)
          expect(user.metadata.bookmarks_count).to eq 1
          expect(user.metadata.public_bookmarks_count).to eq 1
        end
      end

      context 'and has visibility to only_me' do
        it 'increments bookmarks_count only' do
          bookmark = create(:bookmark_visible_to_only_me, user: user)
          UserMetadataUpdater.update_bookmarks_count(bookmark)
          expect(user.metadata.bookmarks_count).to eq 1
          expect(user.metadata.public_bookmarks_count).to eq 0
        end
      end
    end

    context 'when the bookmark is deleted' do
      let(:user_metadatum) { create(:user_metadatum, bookmarks_count: 2, public_bookmarks_count: 1) }
      let(:user) { user_metadatum.user }

      context 'and has visibility to everyone' do
        it 'decrements bookmarks_count and public_bookmarks_count' do
          bookmark = create(:bookmark_visible_to_everyone, user: user)
          bookmark.destroy
          UserMetadataUpdater.update_bookmarks_count(bookmark)
          expect(user.metadata.bookmarks_count).to eq 1
          expect(user.metadata.public_bookmarks_count).to eq 0
        end
      end

      context 'and has visibility to only_me' do
        it 'decrements bookmarks_count only' do
          bookmark = create(:bookmark_visible_to_only_me, user: user)
          bookmark.destroy
          UserMetadataUpdater.update_bookmarks_count(bookmark)
          user.metadata.reload
          expect(user.metadata.bookmarks_count).to eq 1
          expect(user.metadata.public_bookmarks_count).to eq 1
        end
      end
    end
  end

  describe 'reset_user_metadatum' do
    it 'resets user_metadatum counters' do
      user = create(:user)
      other_users = create_list(:user, 2)

      other_users.each do |other_user|
        user.follow(other_user)
      end

      first_other_user = other_users.first
      first_other_user.follow(user)

      create(:bookmark_visible_to_only_me, user: user)
      create_list(:bookmark_visible_to_everyone, 2, user: user)

      UserMetadataUpdater.reset_user_metadatum(user)
      UserMetadataUpdater.reset_user_metadatum(first_other_user)

      user.metadata.reload
      first_other_user.metadata.reload

      expect(user.metadata.followers_count).to eq 1
      expect(user.metadata.followings_count).to eq 2
      expect(user.metadata.bookmarks_count).to eq 3
      expect(user.metadata.public_bookmarks_count).to eq 2

      expect(first_other_user.metadata.followers_count).to eq 1
      expect(first_other_user.metadata.followings_count).to eq 1
    end
  end
end
