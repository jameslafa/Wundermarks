feature 'BookmarkNavigation' do
  let(:user_profile) { create(:user_profile)}
  let(:current_user) { user_profile.user }
  let!(:bookmark) { create(:bookmark_with_tags, user: user_profile.user) }

  scenario 'non signed in user visits a bookmark' do
    visit bookmark_path(bookmark)

    within '.navbar.navbar-default' do
      expect(page).not_to have_link(nil, href: bookmarks_path)
      expect(page).not_to have_css('form')
    end

    within '.user-date' do
      expect(page).to have_link("#{user_profile.name} @#{user_profile.username}")
    end

    within('.header .title') do
      expect(page).to have_content(bookmark.title)
    end

    within('.tags') do
      first_tag = bookmark.tags.first.name
      expect(page).to have_content(first_tag)
      expect(page).not_to have_link(first_tag), "expect tag not to be a link"
    end
  end

  scenario 'signed in user visits a one of his bookmark' do
    login_as(current_user, :scope => :user)

    visit bookmark_path(bookmark)

    within '.navbar.navbar-default' do
      expect(page).to have_link(nil, href: feed_path)
      expect(page).to have_link(nil, href: user_profiles_path)
      expect(page).to have_css('form')
    end

    within '.user-date' do
      expect(page).to have_link("#{user_profile.name} @#{user_profile.username}")
    end

    within '.actions' do
      expect(page).to have_link(I18n.t("actions.edit"), href: edit_bookmark_path(bookmark))
      expect(page).to have_link(I18n.t("actions.delete"), href: bookmark_path(bookmark))
      expect(page).not_to have_link(nil, href: copy_bookmark_path(bookmark))
    end

    within('.header .title') do
      expect(page).to have_content(bookmark.title)
    end

    within('.tags') do
      first_tag = bookmark.tags.first
      expect(page).to have_link(first_tag.name, href:bookmarks_path(q: first_tag.name)), "expect tag to root to bookmarks"
    end
  end

  scenario 'signed in user visits a bookmark of another user' do
    login_as(create(:user_profile).user, :scope => :user)

    visit bookmark_path(bookmark)

    within '.navbar.navbar-default' do
      expect(page).to have_link(nil, href: feed_path)
      expect(page).to have_link(nil, href: user_profiles_path)
      expect(page).to have_css('form')
    end

    within '.actions' do
      expect(page).not_to have_link(I18n.t("actions.edit"), href: edit_bookmark_path(bookmark))
      expect(page).not_to have_link(I18n.t("actions.delete"), href: bookmark_path(bookmark))
      expect(page).to have_link(nil, href: copy_bookmark_path(bookmark))
    end

    within '.user-date' do
      expect(page).to have_link("#{user_profile.name} @#{user_profile.username}")
    end

    within('.header .title') do
      expect(page).to have_content(bookmark.title)
    end

    within('.tags') do
      tag = first('.tag')
      expect(tag[:href]).to eq(bookmarks_path(q: tag.text)), "expect tag to root to bookmarks"
    end
  end
end
