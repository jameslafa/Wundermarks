require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:username).case_insensitive.allow_blank }
  it { is_expected.to validate_length_of(:username).is_at_least(5).is_at_most(20) }
  it { is_expected.to allow_values('johnsnow', 'james').for(:username) }
  it { is_expected.not_to allow_values('john', 'john.snow', '@johnsnow', 'john_snow').for(:username) }

  describe 'username=' do
    it 'downcases the username' do
      user_profile = UserProfile.new(username: "JohnSnow")
      expect(user_profile.username).to eq "johnsnow"
    end

    it 'removes serounding whitespaces' do
      user_profile = UserProfile.new(username: "  JohnSnow  ")
      expect(user_profile.username).to eq "johnsnow"
    end

    it 'accepts nil value' do
      user_profile = UserProfile.new(username: nil)
      expect(user_profile.username).to be_nil
    end
  end

  describe 'validations' do
    describe 'username' do
      context 'when user_profile had a username' do
        it 'it rejects a nil value and restore the previous username' do
          user_profile = build(:user_profile, username: nil)
          expect(user_profile).to be_valid
          user_profile.save
          expect(user_profile).to be_persisted
          user_profile.username = 'johnsnow'
          user_profile.save
          user_profile.username = nil
          expect(user_profile).not_to be_valid
          expect(user_profile.errors.messages[:username]).to eq [I18n.t("activerecord.errors.models.user_profile.attributes.username.cannot_be_erase")]
          expect(user_profile.username).to eq 'johnsnow'
        end
      end
    end
  end
end
