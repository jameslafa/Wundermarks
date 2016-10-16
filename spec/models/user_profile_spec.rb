require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:username).case_insensitive.allow_blank }
  it { is_expected.to validate_length_of(:username).is_at_least(5).is_at_most(20) }
  it { is_expected.to allow_values('johnsnow', 'james').for(:username) }
  it { is_expected.not_to allow_values('john', 'john.snow', '@johnsnow', 'john_snow').for(:username) }
  it { is_expected.to validate_inclusion_of(:country).in_array(ISO3166::Country.codes).allow_blank }

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

  describe 'twitter_username=' do
    it "removes unwanted characters" do
      user_profile = build_stubbed(:user_profile)
      user_profile.twitter_username = '@wundermarks'
      expect(user_profile.twitter_username).to eq 'wundermarks'
      user_profile.twitter_username = '@wunder.marks'
      expect(user_profile.twitter_username).to eq 'wundermarks'
      user_profile.twitter_username = 'wunder_marks'
      expect(user_profile.twitter_username).to eq 'wunder_marks'
    end
  end

  describe 'github_username=' do
    it "removes unwanted characters" do
      user_profile = build_stubbed(:user_profile)
      user_profile.github_username = '@wundermarks'
      expect(user_profile.github_username).to eq 'wundermarks'
      user_profile.github_username = '@wunder.marks'
      expect(user_profile.github_username).to eq 'wundermarks'
      user_profile.github_username = 'wunder-marks'
      expect(user_profile.github_username).to eq 'wunder-marks'
    end
  end

  describe 'website=' do
    it "adds http:// if missing" do
      user_profile = build_stubbed(:user_profile)
      user_profile.website = 'wundermarks.com'
      expect(user_profile.website).to eq 'http://wundermarks.com'
      user_profile.website = 'https://wundermarks.com'
      expect(user_profile.website).to eq 'https://wundermarks.com'
      user_profile.website = 'http://wundermarks.com'
      expect(user_profile.website).to eq 'http://wundermarks.com'
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

    describe 'website' do
      it 'validates website urls' do
        user_profile = build_stubbed(:user_profile)
        user_profile.website = 'https://wundermarks.com'
        expect(user_profile).to be_valid
        user_profile.website = 'http://wundermarks.com'
        expect(user_profile).to be_valid
        user_profile.website = 'wundermarks.com'
        expect(user_profile).to be_valid
        user_profile.website = 'https://wundermarks'
        expect(user_profile).not_to be_valid
        expect(user_profile.errors.messages[:website].first).to eq I18n.t('activerecord.errors.models.user_profile.attributes.website.invalid')
      end
    end

    describe 'birthday' do
      it 'validates the date' do
        user_profile = build_stubbed(:user_profile)
        user_profile.birthday = Date.today - 27.years
        expect(user_profile).to be_valid
        user_profile.birthday = Date.today + 1.year
        expect(user_profile).not_to be_valid
        user_profile.birthday = Date.today - 110.year
        expect(user_profile).not_to be_valid
        expect(user_profile.errors.messages[:birthday].first).to eq I18n.t('activerecord.errors.models.user_profile.attributes.birthday.invalid')

      end
    end
  end
end
