feature 'PrivateUserProfile' do
  let(:user_profile) { create(:user_profile) }

  scenario "No logged in user visits a non-public profile" do
    # Set UserProfile to private
    user_profile.user.preferences.update_attributes({"public_profile" => false})

    visit user_profile_path(user_profile.id)
    expect(page).to have_css(".private_user_profile")
    expect(page).to have_meta({"robots" => "noindex"})

    expect(page).not_to have_title "#{I18n.t('meta_tag.site_name')} | #{user_profile.name} (@#{user_profile.username})"
    expect(page).not_to have_meta({
      "description" => user_profile.introduction,
      "twitter:description" => user_profile.introduction,
      "og:url" => Rails.application.routes.url_helpers.user_profile_url(user_profile.id),
      "og:title" => "#{I18n.t('meta_tag.site_name')} | #{user_profile.name} (@#{user_profile.username})",
      "og:description" => user_profile.introduction
    })

  end
end
