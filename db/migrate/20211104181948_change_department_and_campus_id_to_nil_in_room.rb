class ChangeDepartmentAndCampusIdToNilInRoom < ActiveRecord::Migration[6.1]
  def change
    change_column_null :rooms, :campus_records_id, true
    change_column_null :rooms, :departments_id, true
    change_column_default :rooms, :campus_records_id, nil
    change_column_default :rooms, :departments_id, nil
  end
end
