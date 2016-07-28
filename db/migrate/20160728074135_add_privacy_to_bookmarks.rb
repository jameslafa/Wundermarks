class AddPrivacyToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :privacy, :integer, default: 1, null: false
    add_index :bookmarks, :privacy
  end
end
