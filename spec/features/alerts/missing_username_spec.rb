feature 'MissingUsername' do
  scenario "The user has no username defined" do
    user_profile = create(:user_profile, username: nil)
    other_profile = create(:user_profile, username: nil)

    user = user_profile.user

    # User needs at least to have one bookmark to see the notification
    create(:bookmark, user: user)

    login_as(user, :scope => :user)

    # Alert displayed on user's bookmark page
    visit bookmarks_path
    expect(page).to have_css ".alert.missing_username"

    # Alert displayed on user's news feed page
    visit feed_path
    expect(page).to have_css ".alert.missing_username"

    # Alert displayed on user's profile page, if he is the logged in user
    visit user_profile_path(user_profile)
    expect(page).to have_css ".alert.missing_username"
    expect(page).to have_css ".user-profile .user-profile-username a.create_username"

    # Go on the edit user page and set a username
    find(".alert.missing_username a").click

    expect(current_path).to eq edit_current_user_profile_path
    expect(page).not_to have_css ".alert.missing_username"
    fill_in("Username", with: 'johnsnow')
    first('input[name="commit"]').click

    # Now the alert is not displayed
    visit bookmarks_path
    expect(page).not_to have_css ".alert.missing_username"

    # Alert is not displayed on someone else user's profile page
    visit user_profile_path(other_profile)
    expect(page).not_to have_css ".alert.missing_username"
    expect(page).not_to have_css ".user-profile-col .user-profile-username a.create_username"
  end
end
