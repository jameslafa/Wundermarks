require 'rails_helper'

RSpec.describe Notifier, type: :service do

  describe 'bookmark_like' do
    it 'creates a new notification for a bookmark_like activity' do
      bookmark_owner = create(:user)
      liker = create(:user)
      bookmark = create(:bookmark, user: bookmark_owner)

      expect{
        Notifier.bookmark_like(bookmark, liker)
      }.to change(Notification, :count).by(1)

      notification = Notification.last

      expect(notification.sender).to eq liker
      expect(notification.recipient).to eq bookmark_owner
      expect(notification.emitter).to eq bookmark
      expect(notification.activity).to eq 'bookmark_like'
    end
  end

  describe 'bookmark_copy' do
    it 'creates a new notification for a bookmark_copy activity' do
      bookmark_owner = create(:user)
      copier = create(:user)
      bookmark = create(:bookmark, user: bookmark_owner)

      expect{
        Notifier.bookmark_copy(bookmark, copier)
      }.to change(Notification, :count).by(1)

      notification = Notification.last

      expect(notification.sender).to eq copier
      expect(notification.recipient).to eq bookmark_owner
      expect(notification.emitter).to eq bookmark
      expect(notification.activity).to eq 'bookmark_copy'
    end
  end

  describe 'user_follow' do
    it 'creates a new notification for a bookmark_copy activity' do
      followed = create(:user)
      follower = create(:user)

      expect{
        Notifier.user_follow(followed, follower)
      }.to change(Notification, :count).by(1)

      notification = Notification.last

      expect(notification.sender).to eq follower
      expect(notification.recipient).to eq followed
      expect(notification.emitter).to eq followed
      expect(notification.activity).to eq 'user_follow'
    end
  end
end
