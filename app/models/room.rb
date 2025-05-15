# == Schema Information
#
# Table name: rooms
#
#  building_bldrecnbr          :bigint           not null
#  characteristics             :text             default([]), is an Array
#  dept_description            :string
#  dept_grp                    :string
#  facility_code_heprod        :string
#  floor                       :string
#  instructional_seating_count :integer
#  rmrecnbr                    :bigint           not null, primary key
#  rmtyp_description           :string
#  room_number                 :string
#  square_feet                 :integer
#  tsv                         :tsvector
#  visible                     :boolean
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  dept_id                     :integer
#
# Indexes
#
#  index_rooms_on_building_bldrecnbr  (building_bldrecnbr)
#  index_rooms_on_tsv                 (tsv) USING gin
#
# Foreign Keys
#
#  fk_rails_...  (building_bldrecnbr => buildings.bldrecnbr)
#
class Room < ApplicationRecord
  include PgSearch::Model
  self.primary_key = 'rmrecnbr'
  extend OrderAsSpecified

  belongs_to :building, foreign_key: :building_bldrecnbr
  belongs_to :campus_record, optional: true
  has_many :room_characteristics, foreign_key: :rmrecnbr, dependent: :destroy
  has_one :room_contact, foreign_key: :rmrecnbr, dependent: :destroy
  has_one_attached :room_panorama
  has_one_attached :room_image
  has_one_attached :room_layout
  has_many :notes, as: :noteable
  has_one_attached :gallery_image1
  has_one_attached :gallery_image2
  has_one_attached :gallery_image3
  has_one_attached :gallery_image4
  has_one_attached :gallery_image5

  validate :acceptable_image

  multisearchable(
    against: %i[rmrecnbr room_number building_bldrecnbr],
    update_if: :updated_at_changed?
  )

  pg_search_scope(
    :with_building_name,
    associated_against: {
      building: { name: 'A',
                  nick_name: 'B',
                  abbreviation: 'C' }
    },
    using: {
      tsearch: {
        dictionary: 'simple',
        prefix: true,
        any_word: false

      }
    }
  )

  pg_search_scope(
    :with_all_characteristics,
    against: [:characteristics],
    using: {
      tsearch: {
        dictionary: 'simple',
        prefix: false,
        any_word: false
      }
    }
  )

  pg_search_scope(
    :with_school_or_college_name,
    against: [:dept_group_description],
    using: {
      tsearch: {
        dictionary: 'english',
        prefix: true,
        any_word: false
      }
    }
  )

  scope :classrooms, lambda {
    where(rmtyp_description: ['Classroom']).where.not(facility_code_heprod: nil).where('instructional_seating_count > ?', 1)
  }

  scope :classrooms_inactive, lambda {
    where(rmtyp_description: ['Classroom'], visible: false).where.not(facility_code_heprod: nil).where('instructional_seating_count > ?', 1)
  }

  scope :classroom_labs, lambda {
    where(rmtyp_description: ['Class Laboratory'])
  }

  scope :classrooms_including_labs, lambda {
    where(rmtyp_description: ['Classroom', 'Class Laboratory'])
  }

  after_commit :generate_thumbnails, on: %i[create update], if: :room_image_attached?

  def display_name
    if nickname.present?
      "#{facility_code_heprod} - #{nickname}"
    else
      "#{facility_code_heprod}"
    end
  end

  def acceptable_image
    unless room_panorama.attached? || room_image.attached? || room_layout.attached? || gallery_image1.attached? || gallery_image2.attached? || gallery_image3.attached? || gallery_image4.attached? || gallery_image5.attached?
      return
    end

    [room_panorama, room_image, room_layout, gallery_image1, gallery_image2, gallery_image3, gallery_image4,
     gallery_image5].compact.each do |image|
      next unless image.attached?

      errors.add(image.name, 'is too big') unless image.blob.byte_size <= 10.megabyte

      acceptable_types = ['image/png', 'image/jpeg', 'image/webp', 'application/pdf']
      errors.add(image.name, 'incorrect file type') unless acceptable_types.include?(image.content_type)
    end
  end

  def generate_thumbnails
    return unless room_image.attached? && room_image.blob.present?

    ProcessThumbnailJob.perform_later(self)
  end

  private

  def room_image_attached?
    room_image.attached?
  end
end
