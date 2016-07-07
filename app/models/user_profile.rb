class UserProfile < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_profile

  validates_presence_of :user, :name
end
