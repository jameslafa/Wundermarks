feature 'Authentication' do
  describe 'homepage' do
    describe 'navigation bar' do
      it "needs to be rewritten"
    end
  end

  scenario 'it redirects to the wished page after sign_in' do
    user_profile =  create(:user_profile)
    user = user_profile.user

    # Have to set the host, there is still an open issue with capybara and default_url_options is being ignored
    # https://github.com/rspec/rspec-rails/issues/1275
    wished_path = new_bookmark_path(title: 'my title', description: 'my description', url: "https://google.com", host: "test.host")
    visit wished_path
    expect(current_path).to eq new_user_session_path

    fill_in("Email", with: user.email)
    fill_in("Password", with: 'wrong password')
    first('input[name="commit"]').click

    expect(current_path).to eq new_user_session_path

    fill_in("Email", with: user.email)
    fill_in("Password", with: attributes_for(:user).slice(:password)[:password])
    first('input[name="commit"]').click

    expect(current_url).to eq "http://test.host#{wished_path}"
  end
end
