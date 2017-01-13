feature "GettingStarted" do
  scenario "The user hasn't created any bookmark yet" do
    user_profile = create(:user_profile)
    user = user_profile.user

    login_as(user, :scope => :user)

    visit feed_path
    expect(current_path).to eq getting_started_path

    visit bookmarks_path
    expect(current_path).to eq getting_started_path

    bookmark = create(:bookmark, user: user)

    visit feed_path
    expect(current_path).to eq feed_path

    visit bookmarks_path
    expect(current_path).to eq bookmarks_path


  end
end
