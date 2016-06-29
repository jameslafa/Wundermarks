require 'rails_helper'

RSpec.describe BookmarkPolicy do

  subject { described_class }

  let(:user) { create(:user) }
  let(:user_bookmark) { create(:bookmark, user: user) }
  let(:other_user_bookmark) { create(:bookmark) }


  permissions ".scope" do
    let(:resolved_scope) do
      described_class::Scope.new(user, Bookmark.all).resolve
    end

    let!(:user_bookmarks) { create_list(:bookmark, 3, user: user) }
    let!(:other_bookmarks) { create_list(:bookmark, 2) }

    it "includes only user's bookmarks" do
      expect(resolved_scope).to match_array user_bookmarks
    end
  end

  context "when the bookmark belongs to the user" do
    subject { described_class.new(user, user_bookmark) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the bookmark does not belong to the user" do
    subject { described_class.new(user, other_user_bookmark) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
