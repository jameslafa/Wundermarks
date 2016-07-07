class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.text :introduction

      t.timestamps null: false
    end
  end
end
