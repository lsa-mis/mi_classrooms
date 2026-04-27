class UpdateRoomCharacteristicsArrayJob < ApplicationJob
  queue_as :default

  def perform(*)
    update_room_characteristics_array
  end

  def update_room_characteristics_array
    rmrecnbrs = (
      Room.where.not(characteristics: []).pluck(:rmrecnbr) +
      RoomCharacteristic.distinct.pluck(:rmrecnbr)
    ).uniq

    rmrecnbrs.each do |rmrecnbr|
      room = Room.find_by(rmrecnbr: rmrecnbr)
      next unless room

      chars = RoomCharacteristic.where(rmrecnbr: rmrecnbr).pluck(:chrstc_descrshort).uniq.compact.sort

      room.characteristics = chars
      room.save!
    end
  end
end
