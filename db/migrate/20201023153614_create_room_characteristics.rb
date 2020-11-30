class CreateRoomCharacteristics < ActiveRecord::Migration[6.1]
  def change
    create_table :room_characteristics do |t|
      t.references :rmrecnbr, references: :rooms, null: false
      t.integer :chrstc
      t.integer :chrstc_eff_status
      t.string :chrstc_descrshort
      t.string :chrstc_descr
      t.string :chrstc_desc254

      t.timestamps
    end
    rename_column :room_characteristics, :rmrecnbr_id, :rmrecnbr
    add_foreign_key :room_characteristics, :rooms, column: 'rmrecnbr', primary_key: 'rmrecnbr'

  end
end
