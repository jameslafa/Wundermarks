class Notification < ActiveRecord::Base

  # Associations
  belongs_to :recipient, class_name: "User"
  belongs_to :sender, class_name: "User"
  belongs_to :emitter, polymorphic: true

  # Validations
  validates_presence_of :recipient, :sender, :emitter, :activity

  # Scopes
  scope :unread, -> { where(read: false) }

  # Enumerators
  enum activity: {
    'bookmark_copy': 101,
    'bookmark_like': 102,
    'user_follow': 201
  }
end
