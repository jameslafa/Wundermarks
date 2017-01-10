require 'rails_helper'

RSpec.describe BookmarkLike, type: :model do
  it { is_expected.to belong_to(:bookmark).counter_cache(true) }
  it { is_expected.to belong_to :user }
end
