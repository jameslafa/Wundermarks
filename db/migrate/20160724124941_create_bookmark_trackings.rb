class CreateBookmarkTrackings < ActiveRecord::Migration
  def change
    create_table :bookmark_trackings do |t|
      t.belongs_to :bookmark, index: true, foreign_key: true
      t.integer :source
      t.integer :count, default: 0

      t.timestamps null: false
    end

    add_index :bookmark_trackings, [:bookmark_id, :source]
  end
end
