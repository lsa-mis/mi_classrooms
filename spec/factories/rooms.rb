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
    sequence(:rmrecnbr) { |n| 1000000 + n }
    sequence(:building_bldrecnbr) { |n| 2000000 + n }
    characteristics             { [] }
    dept_description            { "Department of #{Faker::Educator.subject}" }
    dept_grp                    { Faker::Educator.university }
    facility_code_heprod        { "#{Faker::Alphanumeric.alpha(number: 2).upcase}#{Faker::Number.number(digits: 3)}" }
    floor                       { Faker::Number.between(from: 1, to: 10).to_s }
    instructional_seating_count { Faker::Number.between(from: 10, to: 500) }
    rmtyp_description           { ['Classroom', 'Class Laboratory', 'Office'].sample }
    room_number                 { Faker::Number.between(from: 100, to: 999).to_s }
    square_feet                 { Faker::Number.between(from: 200, to: 5000) }
    visible                     { true }
    dept_id                     { Faker::Number.between(from: 1, to: 9999) }
  end
end
