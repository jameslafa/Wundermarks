class CreateUserMetadata < ActiveRecord::Migration
  def change
    create_table :user_metadata do |t|
      t.integer :followers_count,         default: 0, index: true
      t.integer :followings_count,        default: 0, index: true
      t.integer :bookmarks_count,         default: 0, index: true
      t.integer :public_bookmarks_count,  default: 0, index: true
      t.references :user

      t.timestamps null: false
    end
  end
end
