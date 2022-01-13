class CreateFloors < ActiveRecord::Migration[6.1]
  def change
    create_table :floors do |t|
      t.string :floor
      t.references :building_bldrecnbr, references: :buildings, null: false

      t.timestamps
    end
    rename_column :floors, :building_bldrecnbr_id, :building_bldrecnbr
    add_foreign_key :floors, :buildings, column: 'building_bldrecnbr', primary_key: 'bldrecnbr'

  end
end
