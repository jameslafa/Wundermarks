feature 'MissingUsername' do
  scenario "The user has no username defined" do
    user_profile = create(:user_profile, username: nil)
    user = user_profile.user

    login_as(user, :scope => :user)

    visit root_path
    expect(page).to have_css ".alert.missing_username"
    find(".alert.missing_username a").click

    expect(current_path).to eq edit_current_user_profile_path
    fill_in("Username", with: 'johnsnow')
    first('input[name="commit"]').click

    visit root_path
    expect(page).not_to have_css ".alert.missing_username"
  end
end
