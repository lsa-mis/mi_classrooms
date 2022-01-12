class Floor < ApplicationRecord
  belongs_to :building, foreign_key: :building_bldrecnbr
  has_one_attached :floor_plan
end
