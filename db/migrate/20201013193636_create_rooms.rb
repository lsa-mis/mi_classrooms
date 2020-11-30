class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms, id: false, primary_key: :rmrecnbr do |t|
      t.primary_key :rmrecnbr
      t.string :floor
      t.string :room_number
      t.string :rmtyp_description
      t.integer :dept_id
      t.string :dept_grp
      t.string :dept_description
      t.string :facility_code_heprod
      t.integer :square_feet
      t.integer :instructional_seating_count
      t.text :characteristics, array: true, default: []
      t.boolean :visible
      t.references :building_bldrecnbr, references: :buildings, null: false

      t.timestamps
    end

    rename_column :rooms, :building_bldrecnbr_id, :building_bldrecnbr
    add_foreign_key :rooms, :buildings, column: 'building_bldrecnbr', primary_key: 'bldrecnbr'

  end
end
