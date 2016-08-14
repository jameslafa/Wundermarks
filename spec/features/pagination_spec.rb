feature 'Pagination' do
  let(:user_profile) { create(:user_profile)}
  let(:other_user_profile) { create(:user_profile)}
  let(:current_user) { user_profile.user }
  let(:other_user) { other_user_profile.user }

  before(:each) do
    login_as(current_user, :scope => :user)
  end

  scenario 'User navigates with pagination through his bookmarks' do
    bookmarks = create_list(:bookmark, 3, user: current_user, tag_list: 'javascript')

    # He goes on this bookmark page
    # There no pagination, because he has less than 25 bookmarks
    visit bookmarks_path
    expect(page).not_to have_css(".pagination")

    # We create 49 new bookmarks
    # It will shows pagination with 3 pages
    bookmarks += create_list(:bookmark, 49, user: current_user, tag_list: 'rails')
    visit bookmarks_path
    expect(page).to have_css(".pagination")

    within(".pagination-wrapper.hidden-xs .pagination") do
      expect(page).to have_css("li.active", text: 1)
      expect(page).to have_link("2", href: bookmarks_path(page: 2))
      expect(page).to have_link("3", href: bookmarks_path(page: 3))
    end

    # User now search for the word "rails". It should return 49 links paginated on 2 pages
    visit bookmarks_path(q: 'rails')
    expect(page).to have_css(".pagination")

    within(".pagination-wrapper.hidden-xs .pagination") do
      expect(page).to have_css("li.active", text: 1)
      expect(page).to have_link("2", href: bookmarks_path(page: 2, q: 'rails'))
      expect(page).not_to have_link("3")
    end
  end

  scenario 'User navigates with pagination in his feed' do
    bookmarks = create_list(:bookmark, 3, user: other_user, tag_list: 'javascript')

    # He goes on this bookmark page
    # There no pagination, because he has less than 25 bookmarks
    visit feed_path
    expect(page).not_to have_css(".pagination")

    # We create 49 new bookmarks
    # It will shows pagination with 3 pages
    bookmarks += create_list(:bookmark, 49, user: other_user, tag_list: 'rails')
    visit feed_path
    expect(page).to have_css(".pagination")

    within(".pagination-wrapper.hidden-xs .pagination") do
      expect(page).to have_css("li.active", text: 1)
      expect(page).to have_link("2", href: feed_path(page: 2))
      expect(page).to have_link("3", href: feed_path(page: 3))
    end

    # User now search for the word "rails". It should return 49 links paginated on 2 pages
    visit feed_path(q: 'rails')
    expect(page).to have_css(".pagination")

    within(".pagination-wrapper.hidden-xs .pagination") do
      expect(page).to have_css("li.active", text: 1)
      expect(page).to have_link("2", href: feed_path(page: 2, q: 'rails'))
      expect(page).not_to have_link("3")
    end
  end
end
