class UserPreference < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_preference
end
