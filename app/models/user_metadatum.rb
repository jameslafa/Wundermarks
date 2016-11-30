class UserMetadatum < ActiveRecord::Base
  belongs_to :user, inverse_of: :user_metadatum
end
