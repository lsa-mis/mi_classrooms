class CreateBuildings < ActiveRecord::Migration[6.1]
  def change
    create_table :buildings, id: false, primary_key: :bldrecnbr do |t|
      t.integer :bldrecnbr
      t.float :latitude
      t.float :longitude
      t.string :name
      t.string :nick_name
      t.string :abbreviation
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      t.timestamps
    end
  end
end
