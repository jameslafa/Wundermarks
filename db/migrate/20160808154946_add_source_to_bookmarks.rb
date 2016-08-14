class AddSourceToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :source, :integer, default: 0
  end
end
