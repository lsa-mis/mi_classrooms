class AddVisibleToBuilding < ActiveRecord::Migration[6.1]
  def change
    add_column :buildings, :visible, :boolean, default: true
  end
end
