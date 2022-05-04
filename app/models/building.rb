# == Schema Information
#
# Table name: buildings
#
#  abbreviation :string
#  address      :string
#  bldrecnbr    :bigint           not null, primary key
#  city         :string
#  country      :string
#  latitude     :float
#  longitude    :float
#  name         :string
#  nick_name    :string
#  state        :string
#  tsv          :tsvector
#  zip          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_buildings_on_tsv  (tsv) USING gin
#
class Building < ApplicationRecord
  include PgSearch::Model
  self.primary_key = 'bldrecnbr'
  belongs_to :campus_record, optional: true
  has_many :rooms, primary_key: 'bldrecnbr', foreign_key: 'building_bldrecnbr'
  geocoded_by :address # can also be an IP address
  has_one_attached :building_image
  has_many :floors, primary_key: 'bldrecnbr', foreign_key: 'building_bldrecnbr'
  has_many :notes, as: :noteable

  validate :acceptable_image

  multisearchable(
    against: [:name, :nick_name, :abbreviation, :bldrecnbr],
    update_if: :updated_at_changed?
  )

  pg_search_scope(
    :with_name,
    against: { 
      nick_name: 'A',
      abbreviation: 'B',
      name: 'C'},
    using: {
      tsearch: {
        dictionary: "english",
        prefix: true,
        any_word: false,

      }
    }
  )

  scope :inactive, -> { where(visible: false) }

  scope :ann_arbor_campus, -> {
    where("zip ILIKE ANY ( array[?] )", ["48103%", "48104%", "48105%", "48109%"])
  }

  scope :with_classrooms, -> {
                            joins(:rooms).merge(Room.classrooms)
                          }

  def self.classrooms?
    where(room.classrooms.any?)
  end

  def acceptable_image
    return unless building_image.attached?

    [building_image].compact.each do |image|

      if image.attached?
        unless image.blob.byte_size <= 10.megabyte
          errors.add(image.name, "is too big")
        end

        acceptable_types = ["image/png", "image/jpeg", "application/pdf"]
        unless acceptable_types.include?(image.content_type)
          errors.add(image.name, "incorrect file type")
        end
      end
    end
  end
end
