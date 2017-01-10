require 'rails_helper'

RSpec.describe BookmarkService, type: :service do
  let(:user) { create(:user) }
  let(:bookmark) { create(:bookmark) }


  describe "like" do
    context "when the user has not already liked the bookmark" do
      it "creates a new BookmarkLike" do
        expect{
          BookmarkService.like(bookmark.id, user.id)
        }.to change(BookmarkLike, :count).by(1)
      end

      it "returns the updated bookmark" do
        updated_bookmark = BookmarkService.like(bookmark.id, user.id)
        expect(updated_bookmark.liked?).to be true
        expect(updated_bookmark.likes.size).to eq 1
      end
    end

    context "when the user has already liked the bookmark" do
      it "does not creates a new BookmarkLike" do
        create(:bookmark_like, bookmark_id: bookmark.id, user_id: user.id)

        expect{
          BookmarkService.like(bookmark.id, user.id)
        }.not_to change(BookmarkLike, :count)
      end
    end

    context "when the user likes his own bookmark" do
      let(:bookmark) { create(:bookmark, user: user) }

      it "does not creates a new BookmarkLike" do
        expect{
          BookmarkService.like(bookmark.id, user.id)
        }.not_to change(BookmarkLike, :count)
      end
    end

    context "when the bookmark does not exist" do
      it "raises a RecordNotFound error" do
        expect{
          BookmarkService.like(123, user.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the user does not exist" do
      it "raises a RecordNotFound error" do
        expect{
          BookmarkService.like(bookmark.id, 123)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end



  describe "unlike" do
    context "when the user has already liked the bookmark" do
      it "destroys the BookmarkLike" do
        bookmark_like = create(:bookmark_like, bookmark_id: bookmark.id, user_id: user.id)

        expect{
          BookmarkService.unlike(bookmark.id, user.id)
        }.to change(BookmarkLike, :count).by(-1)
      end

      it "returns the updated bookmark" do
        updated_bookmark = BookmarkService.unlike(bookmark.id, user.id)
        expect(updated_bookmark.liked?).to be false
        expect(updated_bookmark.likes.size).to eq 0
      end
    end

    context "when the user has not already liked the bookmark" do
      it "does not destroy the existing BookmarkLike" do
        expect{
          BookmarkService.unlike(bookmark.id, user.id)
        }.not_to change(BookmarkLike, :count)
      end
    end

    context "when the user unlikes his own bookmark" do
      let(:bookmark) { create(:bookmark, user: user) }

      it "does not destroy the existing BookmarkLike" do
        expect{
          BookmarkService.unlike(bookmark.id, user.id)
        }.not_to change(BookmarkLike, :count)
      end
    end

    context "when the bookmark does not exist" do
      it "raises a RecordNotFound error" do
        expect{
          BookmarkService.unlike(123, user.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the user does not exist" do
      it "raises a RecordNotFound error" do
        expect{
          BookmarkService.unlike(bookmark.id, 123)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end



  describe "set_user_bookmark_likes" do
    let!(:current_user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:bookmarks) { create_list(:bookmark, 5, user: other_user) }

    it "sets the liked status of one user for a bookmarks list" do
      liked_bookmarks = bookmarks.shuffle.first(2)
      liked_bookmark_ids = liked_bookmarks.collect { |b| b.id}

      liked_bookmarks.each do |b|
        create(:bookmark_like, user_id: current_user.id, bookmark_id: b.id)
      end

      bookmarks_list_with_status = BookmarkService.set_user_bookmark_likes(bookmarks, current_user.id)

      bookmarks_list_with_status.each do |b|
        expect(b.liked?).to be(liked_bookmark_ids.include?(b.id))
      end
    end
  end

end
