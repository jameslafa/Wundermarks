class Bookmark < ActiveRecord::Base
  acts_as_ordered_taggable
  belongs_to :user

  validates :title, :url, :user, presence: true

  scope :belonging_to, lambda { |user| where(:user => user) }
end
