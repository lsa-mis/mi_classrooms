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
  include PgSearch::Model
  multisearchable(
    against: [:name, :nick_name, :abbreviation, :bldrecnbr],
    update_if: :updated_at_changed?
  )

  self.primary_key = 'bldrecnbr'
  has_many :rooms, primary_key: 'bldrecnbr', foreign_key: 'building_bldrecnbr'

  geocoded_by :address # can also be an IP address


  pg_search_scope(
    :search_name,
    against: %i(name nick_name abbreviation),
    using: {
      tsearch: {
        dictionary: "english",
        prefix: true,
        any_word: true,

      }
    }
  )


end
