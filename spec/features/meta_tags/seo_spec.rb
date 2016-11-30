feature 'MetaTagsSeo' do

  scenario 'user/robot visits homepage' do
    visit '/'

    expect(page).to have_title "#{I18n.t('meta_tag.site_name')} | #{I18n.t('meta_tag.title')}"
    expect(page).to have_meta({
      "description" => I18n.t('meta_tag.description'),
      "image" => ActionController::Base.helpers.image_url('/homepage/teaser_bg.jpg'),
      "keywords" => %w[bookmarks web mobile free application].join(', '),
      "twitter:site_name" => I18n.t('meta_tag.site_name'),
      "twitter:site" => "@wundermarks",
      "twitter:card" => "summary",
      "twitter:description" => I18n.t('meta_tag.description'),
      "twitter:image" => ActionController::Base.helpers.image_url('/homepage/teaser_bg.jpg'),
      "og:url" => Rails.application.routes.url_helpers.root_url,
      "og:site_name" => I18n.t('meta_tag.site_name'),
      "og:title" => "#{I18n.t('meta_tag.site_name')} | #{I18n.t('meta_tag.title')}",
      "og:description" => I18n.t('meta_tag.description'),
      "og:image" => ActionController::Base.helpers.image_url('/homepage/teaser_bg.jpg'),
      "og:type" => "website"
    })
    expect(page).not_to have_meta({"robots" => "noindex"})
  end

  scenario 'user/robot visits bookmark' do
    user_profile = create(:user_profile)
    bookmark = create(:bookmark, user: user_profile.user, title: "My bookmark's title", description: "My bookmark's description" )

    visit bookmark_path(bookmark.id)

    expect(page).to have_title "#{I18n.t('meta_tag.site_name')} | #{bookmark.title}"
    expect(page).to have_meta({
      "description" => bookmark.description,
      "twitter:description" => bookmark.description,
      "og:url" => Rails.application.routes.url_helpers.bookmark_url(bookmark.id),
      "og:title" => "#{I18n.t('meta_tag.site_name')} | #{bookmark.title}",
      "og:description" => bookmark.description
    })
    expect(page).not_to have_meta({"robots" => "noindex"})
  end

  scenario 'user/robot visits profile_page' do
    user_profile = create(:user_profile, introduction: "I'm a very nice user")

    visit user_profile_path(user_profile.id)

    expect(page).to have_title "#{I18n.t('meta_tag.site_name')} | #{user_profile.name} (@#{user_profile.username})"
    expect(page).to have_meta({
      "description" => user_profile.introduction,
      "twitter:description" => user_profile.introduction,
      "og:url" => Rails.application.routes.url_helpers.user_profile_url(user_profile.id),
      "og:title" => "#{I18n.t('meta_tag.site_name')} | #{user_profile.name} (@#{user_profile.username})",
      "og:description" => user_profile.introduction
    })
    expect(page).not_to have_meta({"robots" => "noindex"})
  end
end
