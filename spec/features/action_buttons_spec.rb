feature 'ActionButtons' do
  let!(:user_profile) { create(:user_profile) }
  let!(:other_user_profile) { create(:user_profile) }

  let!(:user) { user_profile.user}
  let!(:other_user) { other_user_profile.user}

  scenario "User visits pages of items belonging to other users" do
    login_as(user, :scope => :user)

    other_user_bookmark = create(:bookmark, user: other_user)

    # No edit button on the user_profile#show page
    visit user_profile_path(other_user_profile.id)
    expect(page).not_to have_link(I18n.t("user_profiles.show.action.edit"))

    # No edit and delete button on the bookmark#show page
    visit bookmark_path(other_user_bookmark.id)
    expect(page).not_to have_link(I18n.t("bookmarks.show.action.edit"))
    expect(page).not_to have_link(I18n.t("bookmarks.show.action.delete"))
  end

  scenario "User visits pages of items belonging to himself" do
    login_as(user, :scope => :user)

    user_bookmark = create(:bookmark, user: user)

    # There is an edit button on the user_profile#show page
    visit user_profile_path(user_profile.id)
    expect(page).to have_link(I18n.t("user_profiles.show.action.edit"))

    # There are edit and delete button on the bookmark#show page
    visit bookmark_path(user_bookmark.id)
    expect(page).to have_link(I18n.t("actions.edit"))
    expect(page).to have_link(I18n.t("actions.delete"))
  end
end
