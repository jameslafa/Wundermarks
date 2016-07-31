feature 'UpgradeBookmarklet' do
  scenario "The user uses an outdated bookmarklet, it shows an alert" do
    user_profile = create(:user_profile)
    user = user_profile.user
    login_as(user, :scope => :user)

    visit new_bookmark_path(url: "https://www.google.com/", title: "Google: search engine", description: "Find everything and spies on you", layout: "popup", v: (Settings.bookmarklet.current_version.to_i - 1000).to_s)

    # On the popup we do not display the alert
    expect(page).not_to have_css ".alert.upgrade_bookmarklet"

    #  When he navigate to another page, it displays the alert
    visit root_path
    expect(page).to have_css ".alert.upgrade_bookmarklet"

    #  It keeps displaying it until he goes on the tools page
    visit bookmarks_path
    expect(page).to have_css ".alert.upgrade_bookmarklet"

    # When the user visit the tool page, we stop displaying it
    visit tools_path
    expect(page).not_to have_css ".alert.upgrade_bookmarklet"
  end
end
