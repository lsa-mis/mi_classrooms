# == Schema Information
#
# Table name: buildings
#
#  abbreviation :string
#  address      :string
#  bldrecnbr    :integer          primary key
#  city         :string
#  country      :string
#  latitude     :float
#  longitude    :float
#  name         :string
#  nick_name    :string
#  state        :string
#  zip          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :building do
    bldrecnbr { 1080023 }
    #latitude { FFaker::Geolocation.lat }
    latitude { 42.2785133809524 }
    longitude { -83.7402616825397 }
    name { "TESTING BUILDNG NAMED FOR BIG DONER" }
    nick_name { "TESTING BUILDING" }
    abbreviation { "TEST" }
    address { "123 TEST AVE" }
    city { "ANN ARBOR" }
    state { "MI" }
    zip { "48109-1055" }
    country { "USA" }
  end
end