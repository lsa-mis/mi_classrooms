class UpdateRoomCharacteristicsArrayJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    update_room_characteristics_array

  end

  def update_room_characteristics_array
    rmrecnbrs = RoomCharacteristic.pluck(:rmrecnbr).uniq
    rmrecnbrs.each do |rmrecnbr|
      room = Room.find_by(rmrecnbr: rmrecnbr)
      chars = RoomCharacteristic.where(rmrecnbr: rmrecnbr).pluck(:chrstc_descrshort).uniq.compact.sort

      room.characteristics = chars
      room.save
    end
  end

end
