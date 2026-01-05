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
    sequence(:bldrecnbr) { |n| 3000000 + n }
    abbreviation { Faker::Alphanumeric.alpha(number: 4).upcase }
    address      { Faker::Address.street_address }
    city         { Faker::Address.city }
    country      { 'United States' }
    latitude     { Faker::Address.latitude }
    longitude    { Faker::Address.longitude }
    name         { Faker::Company.name }
    nick_name    { Faker::Company.buzzword.titleize }
    state        { 'MI' }
    zip          { '48109' }
    visible      { true }
  end
end
