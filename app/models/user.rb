class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # User can follow User: acts_as_follower => https://github.com/tcocca/acts_as_follower
  acts_as_followable
  acts_as_follower

  has_many :bookmarks
  has_one :user_profile, dependent: :destroy, inverse_of: :user
  has_one :user_preference, dependent: :destroy, inverse_of: :user

  # Association aliases
  alias_attribute :profile, :user_profile
  alias_attribute :preferences, :user_preference

  # Nested attributes
  accepts_nested_attributes_for :user_profile

  # Hooks
  before_save :build_missing_preferences

  # Enumerators
  enum role: {
    'regular': 0,
    'admin': 100
  }


  # Returns user's profile name
  def profile_name
    self.user_profile.try(:name)
  end

  def statistics
    {
      'followers_count' => self.followers_by_type_count('User'),
      'following_count' => self.following_by_type_count('User'),
      'bookmarks_count' => self.bookmarks.size
    }
  end


  private

  # If user as no user_preference, we automatically build it
  def build_missing_preferences
    if self.user_preference.blank?
      self.build_user_preference()
    end
  end
end
