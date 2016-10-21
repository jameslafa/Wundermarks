feature 'FollowUser' do
  let!(:user_profile) { create(:user_profile)}
  let!(:current_user) { user_profile.user }

  let!(:other_user_profile) { create(:user_profile)}
  let!(:other_user) { other_user_profile.user }

  scenario 'user follow and unfollow another user' do
    login_as(current_user, :scope => :user)

    visit user_profile_path(other_user_profile.username)

    follow_link = find_link(I18n.t("user_profiles.user_profile_bar.follow"))
    expect(follow_link['href']).to eq user_relationships_path(user_id: other_user_profile.user.id)
    expect(follow_link['data-method']).to eq 'post'

    follow_link.click

    expect(current_path).to eq user_profile_path(other_user_profile.username)
    expect(current_user.following?(other_user)).to be_truthy

    following_link = find_link(I18n.t("user_profiles.user_profile_bar.following"))
    expect(following_link['href']).to eq user_relationship_path(other_user_profile.user.id)
    expect(following_link['data-method']).to eq 'delete'

    following_link.click

    expect(current_path).to eq user_profile_path(other_user_profile.username)
    expect(current_user.following?(other_user)).to be_falsy
  end
end
