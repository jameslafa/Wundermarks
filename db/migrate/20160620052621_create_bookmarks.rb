class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :title
      t.text :description
      t.string :url
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :bookmarks, :url
  end
end
