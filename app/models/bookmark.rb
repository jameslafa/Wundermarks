class Bookmark < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, :against => {
    tag_search: 'A',
    title: 'B',
    description: 'C'
  }

  acts_as_ordered_taggable
  belongs_to :user

  validates :title, :url, :user, presence: true
  validate :max_5_tags

  scope :belonging_to, lambda { |user| where(:user => user) }

  # Update tag_search while saving
  before_save :update_tag_search

  private

  def max_5_tags
    if self.tag_list.size > 5
      errors.add(:tag_list, I18n.t("activerecord.errors.models.bookmark.attributes.tag_list.too_many"))
    end
  end

  # Save the tags into a field that will be used for tsearch
  def update_tag_search
    self.tag_search = self.tag_list.join(" ")
  end
end
