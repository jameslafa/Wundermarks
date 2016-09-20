class AddCopyFromBookmarkIdToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :copy_from_bookmark_id, :integer
    add_index :bookmarks, :copy_from_bookmark_id
  end
end
