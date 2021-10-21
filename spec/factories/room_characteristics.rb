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

FactoryBot.define do
  factory :room_characteristic do
    chrstc            { Faker::Number.number(digits: 3) }
    chrstc_desc254    { Faker::String.random(length: 6..60) }
    chrstc_descr      { Faker::String.random(length: 6..22) }
    chrstc_descrshort { Faker::String.random(length: 6..12) }
    chrstc_eff_status { Faker::Number.number }
    rmrecnbr          { Faker::Number.number(digits: 7) }
    
  end
end
