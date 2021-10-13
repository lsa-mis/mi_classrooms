class RoomContact < ApplicationRecord
  belongs_to :room, foreign_key: :rmrecnbr, dependent: :destroy

  validates_presence_of :rmrecnbr
end
