module Helpers
  def response_body
    JSON.parse(response.body)
  end

  def sign_in_user(user=nil)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    user ||= FactoryGirl.create(:user)
    sign_in user
  end
end
