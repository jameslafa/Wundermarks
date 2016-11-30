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

  describe 'user_profile_place' do
    it 'returns the city and country of the user' do
      user_profile = build_stubbed(:user_profile, city: 'Berlin', country: 'de')
      expect(user_profile_place(user_profile)).to eq('Berlin, Germany')
      user_profile.attributes = {city: 'Berlin', country: nil}
      expect(user_profile_place(user_profile)).to eq('Berlin')
      user_profile.attributes = {city: nil, country: 'de'}
      expect(user_profile_place(user_profile)).to eq('Germany')
      user_profile.attributes = {city: nil, country: nil}
      expect(user_profile_place(user_profile)).to be_nil
    end
  end

  describe 'get_country_name_from_code' do
    it 'returns the translated country name from a country code' do
      expect(get_country_name_from_code('de')).to eq 'Germany'
      expect(get_country_name_from_code('fr')).to eq 'France'
    end
  end

  describe 'twitter_link' do
    it 'returns the full twitter account url with optional parameters' do
      expect(twitter_link('wundermarks')).to eq '<a target="_blank" rel="nofollow" href="https://twitter.com/wundermarks">@wundermarks</a>'
      expect(twitter_link('wundermarks', {})).to eq '<a href="https://twitter.com/wundermarks">@wundermarks</a>'
    end
  end

  describe 'github_link' do
    it 'returns the full github account url with optional parameters' do
      expect(github_link('wundermarks')).to eq '<a target="_blank" rel="nofollow" href="https://github.com/wundermarks">@wundermarks</a>'
      expect(github_link('wundermarks', {})).to eq '<a href="https://github.com/wundermarks">@wundermarks</a>'
    end
  end
end
