require 'rails_helper'
include UserProfilesHelper

RSpec.describe 'UserProfilesHelper', :type => :helper do
  let(:user_profile) { build_stubbed(:user_profile) }

  describe 'user_profile_permalink' do
    context 'with full_url == false' do
      it 'returns the user_profile_path with username' do
        expect(user_profile_permalink(user_profile, false)).to eq "/profile/#{user_profile.username}"
      end
    end

    context 'with full_url == true' do
      it 'returns the user_profile_url with username' do
        expect(user_profile_permalink(user_profile, true)).to eq "http://test.host/profile/#{user_profile.username}"
      end
    end

    context 'with a profile which has no username' do
      it 'returns the user_profile_path with id' do
        user_profile.username = nil
        expect(user_profile_permalink(user_profile, false)).to eq "/profile/#{user_profile.id}"
      end
    end
  end
end
