class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :noteable, polymorphic: true, null: false
      t.integer :parent_id

      t.timestamps
    end
  end
end
