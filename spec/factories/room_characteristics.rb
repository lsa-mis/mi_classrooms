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
    association :room
    rmrecnbr { room&.rmrecnbr || FactoryBot.create(:room).rmrecnbr }
    chrstc { Faker::Number.between(from: 1, to: 100) }
    chrstc_descr { ['Projector: Digital', 'WiFi', 'Chalkboard: >25sq ft', 'Team: Tables', 'Document Camera'].sample }
    chrstc_descrshort { ['ProjDigit', 'WiFi', 'Chkbrd>25', 'TeamTables', 'DocCam'].sample }
    chrstc_desc254 { chrstc_descr }
    chrstc_eff_status { 1 }

    trait :projector do
      chrstc_descr { 'Projector: Digital' }
      chrstc_descrshort { 'ProjDigit' }
    end

    trait :wifi do
      chrstc_descr { 'WiFi' }
      chrstc_descrshort { 'WiFi' }
    end

    trait :chalkboard do
      chrstc_descr { 'Chalkboard: >25sq ft' }
      chrstc_descrshort { 'Chkbrd>25' }
    end

    trait :team_tables do
      chrstc_descr { 'Team: Tables' }
      chrstc_descrshort { 'TeamTables' }
    end
  end
end