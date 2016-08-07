module Helpers
  def response_body
    JSON.parse(response.body)
  end

  def sign_in_user(user=nil)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user ||= FactoryGirl.create(:user)
    user.user_profile ||= build(:user_profile, user: user)
    user.user_profile.save
    sign_in user
  end
end
