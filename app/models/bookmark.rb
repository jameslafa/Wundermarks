class Bookmark < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search, :against => {
    tag_search: 'A',
    title: 'B',
    description: 'C'
  }

  acts_as_ordered_taggable
  belongs_to :user
  has_many :bookmark_trackings

  validates :title, :url, :user, presence: true
  validate :max_5_tags

  scope :belonging_to, lambda { |user| where(:user => user) }

  # Update tag_search while saving
  before_save :update_tag_search

  def url_domain
    if url.present?
      uri = URI(url)
      uri.host
    end
  end

  def sharing_statistics
    trackings = self.bookmark_trackings

    statistics = ActiveSupport::OrderedHash.new
    BookmarkTracking.sources.keys.each do |source|
      statistics[source.to_s] = 0
    end

    total = 0
    trackings.each do |tracking|
      statistics[tracking.source.to_s] = tracking.count
      total += tracking.count
    end
    
    statistics["total"] = total
    statistics
  end

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
