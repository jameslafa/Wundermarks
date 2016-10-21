require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many :bookmarks }
  it { is_expected.to have_one :user_profile }
  it { is_expected.to have_one :user_preference }
  it { is_expected.to define_enum_for(:role).with({regular: 0, admin: 100}) }

  describe 'profile_name' do
    let(:user) { create(:user) }
    let!(:profile) { create(:user_profile, user_id: user.id) }

    it "returns the profile name" do
      expect(user.profile_name).to eq profile.name
    end
  end

  describe 'statistics' do
    let(:user) { create(:user) }

    it "returns the number of bookmarks of the user" do
      bookmarks = create_list(:bookmark, 2, user: user)
      expect(user.statistics['bookmarks_count']).to eq bookmarks.size
    end

    it "returns the number of people following the user" do
      other_users = create_list(:user, 3)
      other_users.each do |other_user|
        other_user.follow(user)
      end
      expect(user.statistics['followers_count']).to eq other_users.size
    end

    it "returns the number of people that the user follow" do
      other_users = create_list(:user, 2)
      other_users.each do |other_user|
        user.follow(other_user)
      end
      expect(user.statistics['following_count']).to eq other_users.size
    end
  end

  describe 'preferences' do
    it 'returns the associated user_prefrence' do
      user = build(:user)
      user_prefrence = user.create_user_preference()
      expect(user.preferences).to eq user_prefrence
    end
  end

  describe 'profile' do
    it 'returns the associated user_profile' do
      user = build(:user)
      user_profile = user.create_user_profile()
      expect(user.profile).to eq user_profile
    end
  end

  describe 'build_missing_preferences' do
    it 'build missing user_preference when user is save' do
      user = build(:user)
      user.save
      expect(UserPreference.find_by(user_id: user.id)).to be_truthy
    end
  end
end
