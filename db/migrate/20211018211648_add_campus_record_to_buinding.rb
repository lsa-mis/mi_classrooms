class AddCampusRecordToBuinding < ActiveRecord::Migration[6.1]
  def change
    add_reference :buildings, :campus_record, foreign_key: true
  end
end
