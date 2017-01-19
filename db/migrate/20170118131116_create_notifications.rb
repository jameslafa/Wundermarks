class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :recipient_id, index: true
      t.integer :sender_id
      t.integer :activity
      t.references :emitter, polymorphic: true, index: true
      t.boolean :read, index: true, default: false
      t.datetime :read_at

      t.timestamps null: false
    end
  end
end
