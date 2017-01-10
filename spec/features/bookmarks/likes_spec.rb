feature "BookmarkLikes" do
  let!(:current_profile) { create(:user_profile) }
  let!(:other_profile) { create(:user_profile) }

  let(:current_user) { current_profile.user }
  let(:other_user) { other_profile.user }

  scenario "User likes someone else's bookmark" do
    # Create bookmarks
    current_user_bookmark = create(:bookmark, user: current_user)
    other_user_bookmark = create(:bookmark, user: other_user)

    # Make current_user follow other_user to see his bookmarks in the feed
    current_user.follow(other_user)
    login_as(current_user, :scope => :user)

    # Go on the feed page
    visit feed_path

    # Search for bookmark like link on other_user's bookmark
    expect(page).to have_link(nil, href: like_bookmark_path(bookmark_id: other_user_bookmark.id))

    # Check that current_user's bookmark has no like link
    expect(page).not_to have_link(nil, href: like_bookmark_path(bookmark_id: current_user_bookmark.id))

    # Click on the like link
    bookmark_like_link = find_link(href: like_bookmark_path(bookmark_id: other_user_bookmark.id))
    bookmark_like_link.click

    expect(current_path).to eq bookmark_path(id: other_user_bookmark.id)

    # Go back to feed and check that there is now a new like
    visit feed_path

    updated_liked_button = find_by_id("bookmark-like-button-#{other_user_bookmark.id}")
    expect(updated_liked_button).to have_text "1"
  end
end
