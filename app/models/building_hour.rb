class BuildingHour < ApplicationRecord
  belongs_to :building, foreign_key: :building_bldrecnbr
end
