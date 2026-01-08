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
    sequence(:chrstc) { |n| n }
    chrstc_desc254    { Faker::Lorem.sentence }
    chrstc_descr      { Faker::Lorem.words(number: 3).join(' ') }
    chrstc_descrshort { %w[ProjDigit Whtbrd Chkbrd DocCam BluRay InstrComp TeamBoard LectureCap VideoConf].sample }
    chrstc_eff_status { 1 }
    sequence(:rmrecnbr) { |n| 1000000 + n }
  end
end
