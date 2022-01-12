class Floor < ApplicationRecord
  belongs_to :building, foreign_key: :building_bldrecnbr
  has_one_attached :floor_plan

  validates_uniqueness_of :floor, :scope => :building_bldrecnbr, :message => '- combination of floor and building_bldrecnbr should be unique'


end
