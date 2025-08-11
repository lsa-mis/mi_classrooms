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
    abbreviation { Faker::Alphanumeric.alpha(number: 4).upcase }
    address { Faker::Address.street_address }
    bldrecnbr { Faker::Number.unique.number(digits: 8) }
    city { "Ann Arbor" }
    country { "USA" }
    latitude { Faker::Address.latitude.to_f.round(6) }
    longitude { Faker::Address.longitude.to_f.round(6) }
    name { Faker::University.name + " Building" }
    nick_name { Faker::Lorem.words(number: 2).join(" ").titleize }
    state { "MI" }
    zip { ["48103", "48104", "48105", "48109"].sample }
    visible { true }

    trait :inactive do
      visible { false }
    end

    trait :with_campus_record do
      association :campus_record
    end
  end
end