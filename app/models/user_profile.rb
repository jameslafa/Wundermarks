class UserProfile < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_profile

  # CarrierWave
  mount_uploader :avatar, AvatarUploader

  validates_presence_of :user, :name
  validates_uniqueness_of :username, case_sensitive: false, allow_blank: true
  validates :username, length: { minimum: 5, maximum: 20 }, allow_blank: true
  validates :username, format: {with: /\A[a-zA-Z0-9]+\z/}, allow_blank: true
  validates :country, inclusion: ISO3166::Country.codes, allow_blank: true
  validates :website, :url => {:allow_blank => true, :no_local => true, :message => I18n.t('activerecord.errors.models.user_profile.attributes.website.invalid') }
  validates :birthday, date: {allow_blank: true, before: Proc.new { Time.now - 5.year }, after: Proc.new { Time.now - 100.year }, :message => I18n.t('activerecord.errors.models.user_profile.attributes.birthday.invalid')}

  validate :username_cannot_be_erase

  # Downcase automatically the username
  def username=(value)
    if value
      value.downcase!
      value.squish!
    end
    super(value)
  end

  def twitter_username=(value)
    if value
      # Remove unwanted characters
      value.gsub!(/[^a-zA-Z0-9_]/, '')
    end
    super(value)
  end

  def github_username=(value)
    if value
      # Remove unwanted characters
      value.gsub!(/[^a-zA-Z0-9-]/, '')
    end
    super(value)
  end

  def website=(value)
    if value
      # Add http:// if does not exist
      if !(value.starts_with?("http://") || value.starts_with?("https://"))
        value = "http://#{value}"
      end
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
