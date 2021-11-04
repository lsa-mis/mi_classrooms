class ChangeDepartmentAndCampusIdToNilInRoom < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rooms, :campus_records_id, true
    change_column_null :rooms, :departments_id, true
    change_column_default :rooms, :campus_records_id, from: 0, to: nil
    change_column_default :rooms, :departments_id, from: 0, to: nil
  end
end
