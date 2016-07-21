class AddTagsSearchToBookmarks < ActiveRecord::Migration
  def change
    enable_extension "btree_gin"

    add_column :bookmarks, :tag_search, :string

    # Index for full-text search
    add_index :bookmarks, :tag_search, using: :gin
    add_index :bookmarks, :title, using: :gin
    add_index :bookmarks, :description, using: :gin

    puts "\n===== ATTENTION ====="
    puts "Don't forget to run the following task:"
    puts "\t rake data_migration:add_bookmark_tag_search"
    puts "===== ATTENTION =====\n"
  end
end
