feature 'CopyBookmark' do
  let(:user_profile) { create(:user_profile)}
  let(:current_user) { user_profile.user }

  let(:other_user_profile) { create(:user_profile)}
  let(:other_user) { other_user_profile.user }

  let!(:original_bookmark) { create(:bookmark_with_tags, user: other_user) }

  scenario 'user copy bookmark from another user' do
    login_as(current_user, :scope => :user)

    # Visit original bookmark page
    visit bookmark_path(original_bookmark)

    # Copy on copy bookmark link
    find(:xpath, "//a[@href='#{copy_bookmark_path(original_bookmark)}']").click

    # Check the field from the original bookmark are filled
    expect(page).to have_field(Bookmark.human_attribute_name(:title), with: original_bookmark.title)
    expect(page).to have_field(Bookmark.human_attribute_name(:description), with: original_bookmark.description)
    expect(page).to have_field(Bookmark.human_attribute_name(:url), with: original_bookmark.url)
    expect(page).to have_field(Bookmark.human_attribute_name(:tag_list), with: original_bookmark.tag_list)

    # Submit the form
    first('input[name="commit"]').click

    # Check that the newly created bookmark has the copy_from_bookmark_id set
    expect(Bookmark.last.copy_from_bookmark_id).to eq original_bookmark.id
  end
end
