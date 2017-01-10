class CreateBookmarkLikes < ActiveRecord::Migration
  def up
    create_table :bookmark_likes do |t|
      t.belongs_to :bookmark, index: true, foreign_key: true
      t.belongs_to :user, index: true, foreign_key: true
      t.timestamps null: false
    end

    # Likes count
    add_column :bookmarks, :bookmark_likes_count, :integer, default: 0
  end

  def down
    drop_table :bookmark_likes

    # Likes count
    remove_column :bookmarks, :bookmark_likes_count
  end
end
