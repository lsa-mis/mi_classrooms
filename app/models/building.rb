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
class Building < ApplicationRecord
  self.primary_key = 'bldrecnbr'
  has_many :rooms, primary_key: 'bldrecnbr', foreign_key: 'building_bldrecnbr'

  geocoded_by :address # can also be an IP address

end
