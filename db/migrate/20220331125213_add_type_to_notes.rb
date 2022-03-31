class AddTypeToNotes < ActiveRecord::Migration[6.1]
  def change
    add_column :notes, :alert, :boolean, default: false
  end
end
