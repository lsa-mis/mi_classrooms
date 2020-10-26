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

  belongs_to :building, foreign_key: :building_bldrecnbr
  has_many :room_characteristics, foreign_key: :rmrecnbr

  multisearchable(
    against: [:rmrecnbr, :room_number, :abbreviation, :building_bldrecnbr],
    update_if: :updated_at_changed?
  )

  pg_search_scope(
    :with_building_name,
    associated_against: {
      building: [:name]
    },
    using: {
      tsearch: {
        dictionary: "english",
        prefix: true,
        any_word: true,

      }
    }
  )

  # pg_search_scope(
  #   :with_all_characteristics,
  #   against: %i(:characteristics),
  #   using: {
  #     tsearch:{
  #       dictionary: "english",
  #       prefix: true,
  #       any_word: true,
  #     }
  #   }
  # )

end

# import the


# rmrecnbr: 2045698,
# chrstc: 19,
# chrstc_descrshort: "VCR",
# chrstc_descr: "Equipment: VCR",
# chrstc_desc254: "Room contains VCR",


# room_characteristics_importer
  # create the constant (or at least check that it hasn't changed?)
  #


  # ROOM_CHARACTERISTICS = {
  #   "DocCam" => {chrstc_descrshort: "DocCam", chrstc_descr: "Equipment: Document Camera", chrstc_desc254: "Room contains a specialized camera for the real-time displaying of documents, texts, or small objects" },

  #   "VCR" => {chrstc_descrshort: "VCR", chrstc_descr: "Equipment: VCR", chrstc_desc254: "Room contains VCR" }

  # }
