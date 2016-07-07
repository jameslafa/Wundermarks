require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many :bookmarks }

  describe 'profile_name' do
    let(:user) { create(:user) }
    let!(:profile) { create(:user_profile, user_id: user.id) }

    it "returns the profile name" do
      expect(user.profile_name).to eq profile.name
    end
  end
end
