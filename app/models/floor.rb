class Floor < ApplicationRecord
  belongs_to :building, foreign_key: :building_bldrecnbr
  has_one_attached :floor_plan

  validates_uniqueness_of :floor, :scope => :building_bldrecnbr, :message => '- combination of floor and building_bldrecnbr should be unique'
  validates :floor_plan, presence: true
  validate :acceptable_floor_plan

  def acceptable_floor_plan
    return unless floor_plan.attached?
    
    acceptable_types = ["image/jpg", "image/jpeg", "image/png"]

    unless floor_plan.byte_size <= 20.megabyte
      errors.add(:floor_plan, "is too big")
    end

    unless acceptable_types.include?(floor_plan.content_type)
      errors.add(:floor_plan, "must be an image")
    end
  end
end
