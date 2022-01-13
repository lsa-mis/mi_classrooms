class AddIndexToRoomCharacteristics < ActiveRecord::Migration[6.1]
  def change
    add_index :room_characteristics, [:chrstc, :rmrecnbr], unique: true
  end
end
