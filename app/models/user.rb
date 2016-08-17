class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :bookmarks
  has_one :user_profile, dependent: :destroy, inverse_of: :user

  accepts_nested_attributes_for :user_profile

  # Enumerators

  enum role: {
    'regular': 0,
    'admin': 100
  }

  # Returns user's profile name
  def profile_name
    self.user_profile.try(:name)
  end
end
