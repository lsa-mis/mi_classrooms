class CreateBuildingHours < ActiveRecord::Migration[6.1]
  def change
    create_table :building_hours, id: false do |t|
      t.references :building_bldrecnbr, references: :buildings, null: false
      t.integer :day_of_week
      t.time :open_time
      t.time :close_time
      t.timestamps
    end

    rename_column :building_hours, :building_bldrecnbr_id, :building_bldrecnbr

    add_foreign_key :building_hours, :buildings, column: 'building_bldrecnbr', primary_key: 'bldrecnbr'
  end
end
