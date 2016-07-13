feature 'Authentication' do
  describe 'navigation' do
    context 'when the user is NOT signed in' do
      it 'shows the sign in and sign up link in the navigation bar' do
        visit root_path
        within(".navbar") do
          expect(page).to have_link(I18n.t('header.sign.sign_in'))
          expect(page).to have_link(I18n.t('header.sign.sign_up'))
        end
      end
    end

    context 'when the user is signed in' do

      before(:each) do
        login_as(current_user, :scope => :user)
        visit root_path
      end

      let!(:profile) { create(:user_profile) }
      let(:current_user) { profile.user }

      it 'shows the user name in the navigation bar' do
        within(".navbar") do
          expect(page).to have_content(profile.name)
        end
      end

      it 'shows a sign out link in the navigation bar' do
        within(".navbar") do
          expect(page).to have_link(I18n.t('header.sign.sign_out'))
        end
      end
    end
  end
end
