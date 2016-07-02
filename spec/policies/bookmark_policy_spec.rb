require 'rails_helper'

RSpec.describe BookmarkPolicy do

  subject { described_class }

  let(:user) { create(:user) }
  let(:user_bookmark) { create(:bookmark, user: user) }
  let(:other_user_bookmark) { create(:bookmark) }

  context "when the bookmark belongs to the user" do
    subject { described_class.new(user, user_bookmark) }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the bookmark does not belong to the user" do
    subject { described_class.new(user, other_user_bookmark) }

    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
