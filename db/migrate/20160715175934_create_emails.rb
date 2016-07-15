class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :user, index: true, foreign_key: true, null: true
      t.string :from
      t.string :to
      t.string :subject
      t.text :text
      t.text :body

      t.timestamps null: false
    end
  end
end
