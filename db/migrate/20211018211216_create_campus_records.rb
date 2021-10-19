class CreateCampusRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :campus_records do |t|
      t.integer :campus_cd
      t.string :campus_description

      t.timestamps
    end
  end
end
