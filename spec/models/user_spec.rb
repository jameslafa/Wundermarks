require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many :bookmarks }
  it { is_expected.to have_many :emails }
  it { is_expected.to have_one :user_profile }

  describe 'profile_name' do
    let(:user) { create(:user) }
    let!(:profile) { create(:user_profile, user_id: user.id) }

    it "returns the profile name" do
      expect(user.profile_name).to eq profile.name
    end
  end
end
