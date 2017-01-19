require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:recipient).class_name('User') }
  it { is_expected.to belong_to(:sender).class_name('User') }
  it { is_expected.to belong_to(:emitter) }
  it { is_expected.to define_enum_for(:activity).with({bookmark_copy: 101, bookmark_like: 102, user_follow: 201}) }

  it { is_expected.to validate_presence_of(:recipient) }
  it { is_expected.to validate_presence_of(:sender) }
  it { is_expected.to validate_presence_of(:emitter) }
  it { is_expected.to validate_presence_of(:activity) }

  describe 'scopes' do
    describe 'unread' do
      it 'returns only unread notifications' do
        sender = create(:user)
        recipient = create(:user)
        bookmark = create(:bookmark)

        unread_notifications = create_list(:unread_notification, 2, sender: sender, recipient: recipient, emitter: bookmark)
        read_notifications = create_list(:read_notification, 1, sender: sender, recipient: recipient, emitter: bookmark)

        expect(Notification.all.unread).to match_array unread_notifications
      end
    end
  end
end
