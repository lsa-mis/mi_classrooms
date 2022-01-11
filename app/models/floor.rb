class Floor < ApplicationRecord
  belongs_to :building
  has_one_attached :floor_plan
end
