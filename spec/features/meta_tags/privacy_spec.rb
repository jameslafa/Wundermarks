feature 'MetaTagsPrivacy' do
  scenario 'robots visits a page with noindex required' do
    user_profile = create(:user_profile)

    # search_engine_index == false => noindex
    user_profile.user.preferences.update_attributes({"search_engine_index" => false})
    visit user_profile_path(user_profile.id)
    expect(page).to have_meta({"robots" => "noindex"})

    # search_engine_index == true => NO noindex
    user_profile.user.preferences.update_attributes({"search_engine_index" => true})
    visit user_profile_path(user_profile.id)
    expect(page).not_to have_meta({"robots" => "noindex"})

    # search_engine_index == true AND public_profile == false => noindex
    user_profile.user.preferences.update_attributes({"search_engine_index" => true, "public_profile" => false})
    visit user_profile_path(user_profile.id)
    expect(page).to have_meta({"robots" => "noindex"})

    # search_engine_index == false AND public_profile == false => noindex
    user_profile.user.preferences.update_attributes({"search_engine_index" => false, "public_profile" => false})
    visit user_profile_path(user_profile.id)
    expect(page).to have_meta({"robots" => "noindex"})
  end
end
