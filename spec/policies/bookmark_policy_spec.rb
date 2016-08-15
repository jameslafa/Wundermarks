require 'rails_helper'

RSpec.describe BookmarkPolicy do

  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'policies' do
    context "when the bookmark belongs to the user" do
      subject { described_class.new(user, create(:bookmark, user: user)) }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }

      context "when privacy is set to everyone" do
        subject { described_class.new(user, create(:bookmark_visible_to_everyone, user: user)) }

        it { is_expected.to permit_action(:show) }
      end

      context "when privacy is set to only me" do
        subject { described_class.new(user, create(:bookmark_visible_to_only_me, user: user)) }

        it { is_expected.to permit_action(:show) }
      end
    end

    context "when the bookmark does not belong to the user" do
      subject { described_class.new(user, create(:bookmark, user: other_user)) }

      it { is_expected.to forbid_action(:update) }
      it { is_expected.to forbid_action(:destroy) }

      context "when privacy is set to everyone" do
        subject { described_class.new(user, create(:bookmark_visible_to_everyone, user: other_user)) }

        it { is_expected.to permit_action(:show) }
      end

      context "when privacy is set to only me" do
        subject { described_class.new(user, create(:bookmark_visible_to_only_me, user: other_user)) }

        it { is_expected.to forbid_action(:show) }
      end
    end
  end

  describe 'scopes' do
    let!(:user_bookmarks) { create_list(:bookmark, 2, user: user) }
    let!(:other_user_public_bookmarks) { create_list(:bookmark, 2, user: other_user) }
    let!(:other_user_private_bookmarks) { create_list(:bookmark_visible_to_only_me, 2, user: other_user) }

    it 'returns all bookmarks the public bookmarks' do
      expect(BookmarkPolicy::Scope.new(user, Bookmark.all).resolve).to match_array([user_bookmarks, other_user_public_bookmarks].flatten)
      expect(BookmarkPolicy::Scope.new(other_user, Bookmark.all).resolve).to match_array([user_bookmarks, other_user_public_bookmarks, other_user_private_bookmarks].flatten)
    end
  end
end
