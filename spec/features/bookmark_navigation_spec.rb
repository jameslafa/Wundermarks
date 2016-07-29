feature 'BookmarkNavigation' do
  let(:user_profile) { create(:user_profile)}
  let!(:bookmark) { create(:bookmark_with_tags, user: user_profile.user) }

  context 'with a logged out user' do

    scenario 'he visits a bookmark page' do
      visit bookmark_path(bookmark)

      within '.navbar.navbar-default' do
        expect(page).not_to have_link(nil, href: bookmarks_path)
        expect(page).not_to have_css('form')
      end

      within('.title') do
        expect(page).to have_content(bookmark.title)
      end

      within('.tags') do
        tag = first('.tag')
        expect(tag[:href]).to be_nil, "expect tag not to be a link"
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

      within '.navbar.navbar-default' do
        expect(page).to have_link(nil, href: bookmarks_path)
        expect(page).to have_css('form')
      end

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
