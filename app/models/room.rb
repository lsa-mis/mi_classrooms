class Room < ApplicationRecord
  belongs_to :buidling, foreign_key: :buidling_bldrecnbr
end
