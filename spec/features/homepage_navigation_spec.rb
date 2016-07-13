feature 'HomepageNavigation' do
  include BookmarksHelper
  
  let(:user_profile) { create(:user_profile)}
  let!(:bookmarks) { create_list(:bookmark_with_tags, 3, user: user_profile.user) }

  context 'with a logged out user' do
    scenario 'he visits the homepage' do
      visit root_path

      expect(page).not_to have_link(nil, href: new_bookmark_path)
      expect(page).to have_selector('.bookmark-item', count: bookmarks.count)

      first_bookmark = first('.bookmark-item')
      within(first_bookmark) do
        within('.title') do
          expect(page).to have_link(bookmarks.last.title, href: bookmark_permalink(bookmarks.last))
        end
        within('.tags') do
          tag = first('.tag')
          expect(tag[:href]).to eq(root_path(q: tag.text)), "expect tag to root to homepage"
        end
      end
    end
  end

  context 'with a logged in user' do
    let(:current_user) { user_profile.user }

    before(:each) do
      login_as(current_user, :scope => :user)
    end

    scenario 'he visits the homepage' do
      visit root_path

      expect(page).to have_link(nil, href: new_bookmark_path)
      expect(page).to have_selector('.bookmark-item', count: bookmarks.count)

      first_bookmark = first('.bookmark-item')
      within(first_bookmark) do
        within('.title') do
          expect(page).to have_link(bookmarks.last.title, href: bookmark_permalink(bookmarks.last))
        end
        within('.tags') do
          tag = first('.tag')
          expect(tag[:href]).to eq(root_path(q: tag.text)), "expect tag to root to homepage"
        end
      end
    end
  end
end
