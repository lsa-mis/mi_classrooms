class RemoveTimesFromBuildingHours < ActiveRecord::Migration[6.1]
  def change
    remove_column :building_hours, :open_time, :time
    remove_column :building_hours, :close_time, :time
  end
end
