feature 'SearchBookmark' do
  let(:user_profile) { create(:user_profile) }
  let(:other_user_profile) { create(:user_profile) }

  let(:user) { user_profile.user }
  let(:other_user) { other_user_profile.user }

  before(:each) do
    login_as(user, :scope => :user)
  end

  scenario "The bookmark exists in the users' bookmarks" do
    my_bookmark = create(:bookmark, title: 'Ruby on Rails', user: user)
    other_bookmark = create(:bookmark, title: 'Ruby on Rails is great', user: other_user)
    search = 'rails'

    visit root_path
    within '.navbar .search-bookmark' do
      fill_in('q', :with => search)
      find('button').click
    end

    # Result on the bookmarks page
    expect(current_path).to eq bookmarks_path
    # Show the notice
    expect(page.html).to include I18n.t("bookmarks.index.search.search_all_wundermarks", count: 1, search_all_url: root_path(q: search))
    # Display the bookmark
    expect(page).to have_selector('.bookmark', count: 1)
    expect(page).to have_content(my_bookmark.title)

    # Click on search all wundermarks
    find('.alert-success a').click

    # Result on the root page
    expect(current_path).to eq root_path

    # Does not show the notice
    expect(page).not_to have_css('.alert')

    # Display the bookmark
    expect(page).to have_selector('.bookmark', count: 2)
    expect(page).to have_content(my_bookmark.title)
    expect(page).to have_content(other_bookmark.title)
  end
end
