class AddIdToBuildingHours < ActiveRecord::Migration[6.1]
  def change
    add_column :building_hours, :id, :primary_key
  end
end
