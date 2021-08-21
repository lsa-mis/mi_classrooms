class RoomContact < ApplicationRecord
  belongs_to :room

  validates_presence_of :rmrecnbr
end
