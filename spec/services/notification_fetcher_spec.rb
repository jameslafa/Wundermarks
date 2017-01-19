require 'rails_helper'

RSpec.describe NotificationFetcher, type: :service do

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:bookmark) { create(:bookmark, user: user) }

  describe 'unread_user_notifications_count' do
    it "returns the number of unread notification of a user" do
      read_notifications = create_list(:read_notification, 2, recipient: user, sender: other_user, emitter: bookmark)
      unread_notifications = create_list(:unread_notification, 5, recipient: user, sender: other_user, emitter: bookmark).to_a

      expect(NotificationFetcher.unread_user_notifications_count(user)).to eq(unread_notifications.size)

      # The count is limited to 11 by default
      unread_notifications << create_list(:unread_notification, 8, recipient: user, sender: other_user, emitter: bookmark).to_a
      expect(NotificationFetcher.unread_user_notifications_count(user)).to eq(11)
    end
  end

  describe 'user_notifications' do
    it "returns the last 10 notifications ordered by creation time" do
      read_notifications = create_list(:read_notification, 2, recipient: user, sender: other_user, emitter: bookmark).to_a
      unread_notifications = create_list(:unread_notification, 5, recipient: user, sender: other_user, emitter: bookmark).to_a

      expected_notifications = unread_notifications.reverse + read_notifications.reverse
      expect(NotificationFetcher.user_notifications(user)).to eq(expected_notifications)

      # Returns only the last 10
      new_unread_notifications = create_list(:unread_notification, 5, recipient: user, sender: other_user, emitter: bookmark).to_a
      expected_notifications = new_unread_notifications.reverse + expected_notifications
      expected_notifications = expected_notifications.take(10)

      expect(NotificationFetcher.user_notifications(user)).to eq(expected_notifications)
    end
  end

  describe 'mark_all_user_notifications_as_read' do
    it "marks every notification of the user as read" do
      create_list(:unread_notification, 3, recipient: user, sender: other_user, emitter: bookmark)
      create_list(:unread_notification, 2, recipient: other_user, sender: user, emitter: bookmark)

      expect(user.notifications.unread.count).to eq 3
      NotificationFetcher.mark_all_user_notifications_as_read(user)
      expect(user.notifications.unread.count).to eq 0
      expect(other_user.notifications.unread.count).to eq 2
    end
  end
end
