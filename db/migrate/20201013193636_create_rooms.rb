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
      t.integer :square_feet
      t.integer :instructional_seating_count
      t.boolean :visible
      t.references :buidling_bldrecnbr, references: :buildings, null: false

      t.timestamps
    end

    rename_column :rooms, :buidling_bldrecnbr_id, :buidling_bldrecnbr
    add_foreign_key :rooms, :buildings, column: 'buidling_bldrecnbr', primary_key: 'bldrecnbr'

  end
end
