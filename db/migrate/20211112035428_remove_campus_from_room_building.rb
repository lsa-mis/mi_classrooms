class RemoveCampusFromRoomBuilding < ActiveRecord::Migration[6.1]
  def change
    remove_column :rooms, :campus_records_id
    remove_column :buildings, :campus_records_id
  end
end
