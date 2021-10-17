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
    building_bldrecnbr          { Faker::Number.number(digits: 7) }
    characteristics             { Faker::String.random(length: 100 .. 1000) }
    dept_description            { Faker::String.random(length: 6..12) }
    dept_grp                    { Faker::String.random(length: 6..12) }
    facility_code_heprod        { Faker::String.random(length: 6..12) }
    floor                       { Faker::String.random(length: 6..12) }
    instructional_seating_count { Faker::Number.number }
    rmrecnbr                    { Faker::Number.number(digits: 7) }
    rmtyp_description           { Faker::String.random(length: 6..12) }
    room_number                 { Faker::String.random(length: 6..12) }
    square_feet                 { Faker::Number.number }
    visible                     { Faker::Boolean.boolean }
    dept_id                     { Faker::Number.number }
  end
end
