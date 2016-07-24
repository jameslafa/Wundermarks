feature 'BookmarkNavigation' do
  let(:user_profile) { create(:user_profile)}
  let!(:bookmark) { create(:bookmark_with_tags, user: user_profile.user) }

  context 'with a logged out user' do
    scenario 'he visits the bookmark page' do
      visit bookmark_path(bookmark)

      expect(page).not_to have_link(nil, href: bookmarks_path)

      within('.title') do
        expect(page).to have_content(bookmark.title)
      end
      within('.tags') do
        tag = first('.tag')
        expect(tag[:href]).to eq(root_path(q: tag.text)), "expect tag to root to homepage"
      end
    end
  end

  context 'with a logged in user' do
    let(:current_user) { user_profile.user }

    before(:each) do
      login_as(current_user, :scope => :user)
    end

    scenario 'he visits the homepage' do
      visit bookmark_path(bookmark)

      expect(page).to have_link(nil, href: bookmarks_path)

      within('.title') do
        expect(page).to have_content(bookmark.title)
      end
      within('.tags') do
        tag = first('.tag')
        expect(tag[:href]).to eq(bookmarks_path(q: tag.text)), "expect tag to root to bookmarks"
      end
    end
  end
end
