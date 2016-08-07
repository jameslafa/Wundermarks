require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def after_sign_in_path_for(resource)
        super resource
    end
  end

  describe 'after_sign_in_path_for' do
    context 'when user has already a username' do
      it 'returns the feed path' do
        user_profile = create(:user_profile)
        expect(controller.after_sign_in_path_for(user_profile.user)).to eq feed_path
      end
    end

    context 'when user has no username set' do
      it 'returns the edit current user profile path' do
        user_profile = create(:user_profile, username: nil)
        expect(controller.after_sign_in_path_for(user_profile.user)).to eq edit_current_user_profile_path
      end
    end
  end
end
