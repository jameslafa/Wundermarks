class UserProfile < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_profile

  validates_presence_of :user, :name
  validates_uniqueness_of :username, case_sensitive: false, allow_blank: true
  validates :username, length: { minimum: 5, maximum: 20 }, allow_blank: true
  validates :username, format: {with: /\A[a-zA-Z0-9]+\z/}, allow_blank: true
  validate :username_cannot_be_erase

  # Downcase automatically the username
  def username=(value)
    if value
      value.downcase!
      value.squish!
    end
    super(value)
  end

  private

  def username_cannot_be_erase
    return if (self.username.present? || !self.persisted?)
    self.errors.add(:username, :cannot_be_erase) if username_was.present?
    self.username = username_was
  end
end
