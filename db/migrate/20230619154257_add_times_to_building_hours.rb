class AddTimesToBuildingHours < ActiveRecord::Migration[6.1]
  def change
    add_column :building_hours, :open_time, :integer
    add_column :building_hours, :close_time, :integer
  end
end
