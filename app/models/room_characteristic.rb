# == Schema Information
#
# Table name: room_characteristics
#
#  id                :bigint           not null, primary key
#  chrstc            :integer
#  chrstc_desc254    :string
#  chrstc_descr      :string
#  chrstc_descrshort :string
#  chrstc_eff_status :integer
#  rmrecnbr          :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_room_characteristics_on_rmrecnbr  (rmrecnbr)
#
# Foreign Keys
#
#  fk_rails_...  (rmrecnbr => rooms.rmrecnbr)
#
class RoomCharacteristic < ApplicationRecord
  belongs_to :room, foreign_key: :rmrecnbr, dependent: :destroy
end
