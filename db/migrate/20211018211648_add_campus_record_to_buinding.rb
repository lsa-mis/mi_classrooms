class AddCampusRecordToBuinding < ActiveRecord::Migration[6.1]
  def change
    add_reference :buildings, :campus_records, foreign_key: true
  end
end
