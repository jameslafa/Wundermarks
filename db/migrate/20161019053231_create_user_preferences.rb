class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.references :user, index: true, foreign_key: true
      t.boolean :search_engine_index, default: true
      t.boolean :public_profile, default: true

      t.timestamps null: false
    end

    add_index :user_preferences, :public_profile
  end
end
