# == Schema Information
#
# Table name: buildings
#
#  abbreviation :string
#  address      :string
#  bldrecnbr    :bigint           not null, primary key
#  city         :string
#  country      :string
#  latitude     :float
#  longitude    :float
#  name         :string
#  nick_name    :string
#  state        :string
#  tsv          :tsvector
#  zip          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_buildings_on_tsv  (tsv) USING gin
#

FactoryBot.define do
  factory :building do
    abbreviation { Faker::String.random(length: 6..12) }
    address      { Faker::Address.full_address }
    bldrecnbr    { Faker::Number.number(digits: 7) }
    city         { Faker::Address.longitude }
    country      { Faker::String.random(length: 6..12) }
    latitude     { Faker::Address.latitude }
    longitude    { Faker::Address.longitude }
    name         { Faker::String.random(length: 6..12) }
    nick_name    { Faker::String.random(length: 6..12) }
    state        { Faker::Address.state }
    zip          { Faker::Address.postcode }
  end
end
