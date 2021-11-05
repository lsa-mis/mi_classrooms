class AddCampusRecordToRoom < ActiveRecord::Migration[6.1]
  def change
    add_reference :rooms, :campus_record, foreign_key: true
  end
end
