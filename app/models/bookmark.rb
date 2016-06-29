class Bookmark < ActiveRecord::Base
  belongs_to :user

  validates :title, :url, :user, presence: true
end
