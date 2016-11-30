feature 'NoFollowing' do
  scenario "The user is following nobody" do
    user_profile = create(:user_profile)
    user = user_profile.user

    other_user_profile = create(:user_profile)
    other_user = other_user_profile.user

    login_as(user, :scope => :user)

    visit feed_path
    expect(page).to have_css ".alert.no-following"

    find(".alert.no-following a").click
    expect(current_path).to eq user_profiles_path

    find(".follow-user-button a.not-following").click

    visit feed_path
    expect(page).not_to have_css ".alert.no-following"
  end
end
