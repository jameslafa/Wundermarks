require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do

  describe "GET #index" do
    context "with a signed_in user " do
      before(:each) { sign_in_user }

      let(:user) { subject.current_user }
      let(:other_user) { create(:user) }
      let(:bookmark) { create(:bookmark, user: user) }

      it "assigns to @notifications the last 10 notifications of the current_user" do
        read_notifications = create_list(:read_notification, 6, recipient: user, sender: other_user, emitter: bookmark)
        unread_notifications = create_list(:unread_notification, 6, recipient: user, sender: other_user, emitter: bookmark)

        get :index
        expect(assigns(:notifications)).to eq(unread_notifications.reverse + read_notifications.reverse.first(4))
      end

      it "marks every user notifications as read" do
        create_list(:unread_notification, 3, recipient: user, sender: other_user, emitter: bookmark)
        get :index

        expect(user.notifications.unread.count).to eq 0
      end

      it "tracks an ahoy event" do
        create_list(:unread_notification, 3, recipient: user, sender: other_user, emitter: bookmark)

        expect{
          get :index
        }.to change(Ahoy::Event, :count).by(1)

        event = Ahoy::Event.last
        expect(event.name).to eq 'notifications-index'
        expect(event.properties).to eq({"user_id" => subject.current_user.id, "unread_count" => 3})
      end
    end

    context "without a signed_in user" do
      it "redirects to new_user_session_path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

end
