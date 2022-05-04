class Floor < ApplicationRecord
  belongs_to :building, foreign_key: :building_bldrecnbr
  has_one_attached :floor_plan

  validates_uniqueness_of :floor, :scope => :building_bldrecnbr, :message => '- combination of floor and building_bldrecnbr should be unique'
  validates :floor_plan, presence: true
  validate :acceptable_image

  def acceptable_image
    return unless floor_plan.attached?

    [floor_plan].compact.each do |image|

      if image.attached?
        unless image.blob.byte_size <= 10.megabyte
          errors.add(image.name, "is too big - file size cannot exceed 10Mbyte")
        end

        acceptable_types = ["image/png", "image/jpeg", "application/pdf"]
        unless acceptable_types.include?(image.content_type)
          errors.add(image.name, "must be file type PDF, JPEG or PNG")
        end
      end
    end
  end
end
