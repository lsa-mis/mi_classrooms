class RoomContact < ApplicationRecord
  belongs_to :room, foreign_key: :rmrecnbr

  validates_presence_of :rmrecnbr
end
