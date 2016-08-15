class Bookmark < ActiveRecord::Base
  # Extensions

  ## Postgres full-text search
  include PgSearch
  pg_search_scope :search, :against => {
    tag_search: 'A',
    title: 'B',
    description: 'C'
  }

  ## Add tags capacities
  acts_as_ordered_taggable


  # Constants

  MAX_TITLE_LENGTH = 80
  MAX_DESCRIPTION_LENGTH = 255

  # Associations
  belongs_to :user
  has_many :bookmark_trackings, dependent: :destroy


  # Validations
  validates_uniqueness_of :url, scope: :user_id
  validates :title, :url, :user, presence: true
  validates :title, length: { maximum: Bookmark::MAX_TITLE_LENGTH }
  validates :description, length: { maximum: Bookmark::MAX_DESCRIPTION_LENGTH }, allow_blank: true
  validate :max_5_tags


  # Scopes
  scope :belonging_to, lambda { |user| where(:user => user) }
  scope :last_first, lambda { |order = nil| order(created_at: (order || :desc)) }
  scope :paginated, lambda { |page_number| paginate(page: page_number) }
  scope :visible_to_everyone, -> { where(privacy: 1) }


  # Hooks

  ## Update tag_search while saving
  before_save :update_tag_search


  # Enums

  ## Privacy
  enum privacy: {
    'everyone': 1,
    'only_me': 2
  }

  enum source: {
    'wundermarks': 0,
    'delicious': 1
  }


  # Instance methods

  # Returns the domain of the bookmark.url
  def url_domain
    if url.present?
      uri = URI(url)
      uri.host
    end
  end

  # Returns a hash with the click statistics per medium
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

  # Validate that there is maximum 5 tags on the bookmark
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
