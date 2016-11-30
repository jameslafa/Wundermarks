class AddBookmarksCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bookmarks_count, :integer
    add_column :users, :wundermarks_count, :integer

    add_index :users, :wundermarks_count
  end
end
