class AddDepartmentRecordToRoom < ActiveRecord::Migration[6.1]
  def change
    add_reference :rooms, :departments, foreign_key: true
  end
end
