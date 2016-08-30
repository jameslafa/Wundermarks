feature 'NewsFeed' do
  let(:user_profile) { create(:user_profile) }
  let(:user) { user_profile.user}

  let(:other_user_profile) { create(:user_profile) }
  let(:other_user) { other_user_profile.user}

  scenario 'User copies a bookmark' do
    login_as(user, :scope => :user)
    users_bookmark = create(:bookmark, user: user)
    other_users_bookmark = create(:bookmark, user: other_user)

    # Copy_bookmark button is visible only for someone else bookmark
    visit feed_path
    expect(page).not_to have_link(nil, href: copy_bookmark_path(users_bookmark))
    expect(page).to have_link(nil, href: copy_bookmark_path(other_users_bookmark))

    # When clicking on the copy bookmark button, bookmark's field are pre-filled
    find("a[href='#{copy_bookmark_path(other_users_bookmark)}']").click

    expect(current_path).to eq copy_bookmark_path(other_users_bookmark)
    within("form.new_bookmark") do
      expect(page).to have_field(Bookmark.human_attribute_name(:title), with: other_users_bookmark.title)
      expect(page).to have_field(Bookmark.human_attribute_name(:url), with: other_users_bookmark.url)
      expect(page).to have_field(Bookmark.human_attribute_name(:description), with: other_users_bookmark.description)
      expect(page).to have_field(Bookmark.human_attribute_name(:tag_list), with: other_users_bookmark.tag_list)
    end
  end
end
