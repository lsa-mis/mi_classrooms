# == Schema Information
#
# Table name: rooms
#
#  building_bldrecnbr          :bigint           not null
#  characteristics             :text             default([]), is an Array
#  dept_description            :string
#  dept_grp                    :string
#  facility_code_heprod        :string
#  floor                       :string
#  instructional_seating_count :integer
#  rmrecnbr                    :bigint           not null, primary key
#  rmtyp_description           :string
#  room_number                 :string
#  square_feet                 :integer
#  tsv                         :tsvector
#  visible                     :boolean
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  dept_id                     :integer
#
# Indexes
#
#  index_rooms_on_building_bldrecnbr  (building_bldrecnbr)
#  index_rooms_on_tsv                 (tsv) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (building_bldrecnbr => buildings.bldrecnbr)
# 

FactoryBot.define do
  factory :room do
    association :building
    building_bldrecnbr { building&.bldrecnbr || FactoryBot.create(:building).bldrecnbr }
    characteristics { [] }
    dept_description { Faker::Educator.subject }
    dept_grp { Faker::Educator.university }
    facility_code_heprod { "#{Faker::Alphanumeric.alpha(number: 3).upcase}#{Faker::Number.number(digits: 3)}" }
    floor { ["B", "1", "2", "3", "4", "5"].sample }
    instructional_seating_count { Faker::Number.between(from: 10, to: 200) }
    rmrecnbr { Faker::Number.unique.number(digits: 8) }
    rmtyp_description { "Classroom" }
    room_number { Faker::Number.number(digits: 3).to_s }
    square_feet { Faker::Number.between(from: 200, to: 2000) }
    visible { true }
    dept_id { Faker::Number.number(digits: 4) }
    nickname { Faker::Lorem.words(number: 2).join(" ").titleize }

    trait :classroom do
      rmtyp_description { "Classroom" }
      instructional_seating_count { Faker::Number.between(from: 20, to: 100) }
      visible { true }
    end

    trait :inactive do
      visible { false }
    end

    trait :lab do
      rmtyp_description { "Class Laboratory" }
    end
  end
end