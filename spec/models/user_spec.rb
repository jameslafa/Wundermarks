require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many :bookmarks }
  it { is_expected.to have_many(:bookmark_likes).dependent(:destroy) }
  it { is_expected.to have_one(:user_profile).dependent(:destroy) }
  it { is_expected.to have_one(:user_preference).dependent(:destroy) }
  it { is_expected.to have_one(:user_metadatum).dependent(:destroy) }
  it { is_expected.to define_enum_for(:role).with({regular: 0, admin: 100}) }

  describe 'profile_name' do
    let(:user) { create(:user) }
    let!(:profile) { create(:user_profile, user_id: user.id) }

    it "returns the profile name" do
      expect(user.profile_name).to eq profile.name
    end
  end

  describe 'attribute aliases' do
    describe 'alias user_preference -> preferences' do
      it 'returns the associated user_preference' do
        user = build(:user)
        user_preference = user.create_user_preference()
        expect(user.preferences).to eq user_preference
      end
    end

    describe 'alias user_profile -> profile' do
      it 'returns the associated user_profile' do
        user = build(:user)
        user_profile = user.create_user_profile()
        expect(user.profile).to eq user_profile
      end
    end

    describe 'alias user_metadatum -> metadata' do
      it 'returns the associated user_metadatum' do
        user = build(:user)
        user_metadatum = user.create_user_metadatum()
        expect(user.metadata).to eq user_metadatum
      end
    end
  end

  describe 'build_missing_preferences' do
    it 'build missing user_preference when user is save' do
      user = build(:user)
      user.save
      expect(UserPreference.find_by(user_id: user.id)).to be_truthy
    end
  end

  describe 'build_missing_metadata' do
    it 'build missing user_metadatum when user is save' do
      user = build(:user)
      user.save
      expect(UserMetadatum.find_by(user_id: user.id)).to be_truthy
    end
  end

  describe 'following_ids' do
    it 'returns the list of IDs the user is following' do
      user = create(:user)
      followings = create_list(:user, 3)

      following_ids = []
      followings.each do |following|
        user.follow(following)
        following_ids << following.id
      end

      expect(user.following_ids).to match_array following_ids
    end
  end
end
