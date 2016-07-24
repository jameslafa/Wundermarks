feature 'HomepageNavigation' do
  include BookmarksHelper
  include ActionView::Helpers::DateHelper

  let(:user_profile) { create(:user_profile)}
  let!(:bookmarks) { create_list(:bookmark_with_tags, 3, user: user_profile.user) }

  before(:each) do
    default_url_options[:host] = "http://test.host" # waiting for a fix: https://github.com/rspec/rspec-rails/issues/1275
  end

  context 'with a logged out user' do
    scenario 'he visits the homepage' do
      visit root_path

      expect(page).not_to have_link(nil, href: new_bookmark_path)
      expect(page).to have_selector('.bookmark', count: bookmarks.count)

      first_bookmark = first('.bookmark')
      last_bookmark = bookmarks.last

      within(first_bookmark) do
        within('.title') do
          expect(page).to have_link(last_bookmark.title, href: bookmark_permalink(last_bookmark))
        end
        within('.user') do
          expect(page).to have_link(last_bookmark.user.user_profile.name, href: user_profile_path(last_bookmark.user.user_profile))
        end
        within('.link') do
          expect(page).to have_link(last_bookmark.url_domain, href: bookmark_url(last_bookmark, redirect: 1))
        end
        within('.time') do
          expect(page).to have_content I18n.t("home.index.time_ago", time: time_ago_in_words(last_bookmark.created_at))
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
    end
  end
end
