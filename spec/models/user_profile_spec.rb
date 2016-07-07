require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:name) }
end
