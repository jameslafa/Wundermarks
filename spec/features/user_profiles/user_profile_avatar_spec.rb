feature 'UserProfileAvatar' do
  let(:user_profile) { create(:user_profile)}
  let(:current_user) { user_profile.user }

  scenario 'user uploads is first avatar' do
    login_as(current_user, :scope => :user)

    # On the user's profile is the default avatar
    visit user_profile_path(user_profile.username)
    avatar = first('.avatar.big img')
    expect(avatar['src']).to eq '/fallbacks/user_profile/avatar/big_ninja.png'

    # User upload a new picture
    visit edit_current_user_profile_path
    attach_file 'user_profile_avatar', File.join(Rails.root,'/spec/fixtures/files/avatar.png'), {visible: false}
    first('input[name="commit"]').click

    # User has the new picture on his profile page
    user_profile.reload
    visit user_profile_path(user_profile.username)
    avatar = first('.avatar.big img')
    expect(avatar['src']).not_to eq '/fallbacks/user_profile/avatar/big_ninja.png'
    expect(avatar['src']).to eq user_profile.avatar.big.url
  end

  scenario 'user uploads avatar with a form error' do
    login_as(current_user, :scope => :user)

    # User attach a new avatar but make a invalid birthday
    visit edit_current_user_profile_path
    attach_file 'user_profile_avatar', File.join(Rails.root,'/spec/fixtures/files/avatar.png'), {visible: false}
    fill_in("user_profile_birthday", with: Date.today)
    first('input[name="commit"]').click

    # Page is diplayed again. Uploaded image is cached and displayed
    avatar_cache = first('#user_profile_avatar_cache', visible: false)
    cached_filename = avatar_cache['value']
    expect(cached_filename).to be_present
    cached_filename = cached_filename.gsub('avatar.png', 'big_avatar.png')
    expect(first('.avatar-container .image')['style']).to eq "background-image: url(/uploads/tmp/#{cached_filename})"

    # Put a valid birthday and submit
    fill_in("user_profile_birthday", with: 20.years.ago.to_date)
    first('input[name="commit"]').click

    # Uploaded picture has been saved
    user_profile.reload
    visit user_profile_path(user_profile.username)
    avatar = first('.avatar.big img')
    expect(avatar['src']).to eq user_profile.avatar.big.url
  end

  scenario 'file selection box opens when user clicks on avatar'
end
