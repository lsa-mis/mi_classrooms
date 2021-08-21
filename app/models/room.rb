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
  has_one :room_contact, foreign_key: :rmrecnbr

  multisearchable(
    against: [:rmrecnbr, :room_number, :building_bldrecnbr],
    update_if: :updated_at_changed?
  )

  pg_search_scope(
    :with_building_name,
    associated_against: {
      building: {nick_name: 'A',
      abbreviation: 'B',
      name: 'C'}
    },
    using: {
      tsearch: {
        dictionary: "english",
        prefix: true,
        any_word: true,

      }
    }
  )

  pg_search_scope(
    :with_characteristic,
    against: [:characteristics],
    using: {
      tsearch:{
        dictionary: "english",
        prefix: true,
        any_word: true,
      }
    }
  )

  pg_search_scope(
    :with_all_characteristics,
    against: [:characteristics],
    using: {
      tsearch:{
        dictionary: "english",
        prefix: true,
        any_word: false,
      }
    }
  )

  scope :classrooms, -> {
    where(rmtyp_description: ["Classroom"])
  }

  scope :classroom_labs, -> {
  where(rmtyp_description: ["Class Laboratory"])
  }

scope :classrooms_including_labs, -> {
  where(rmtyp_description: ["Classroom", "Class Laboratory"])
}

def self.departments
  [['Academic and Budget Affairs', 'ACAD_&_BDGT_AFFAIRS'],['College of LSA','COLLEGE_OF_LSA'], ['College of Pharmacy','COLLEGE_PHARMACY'], ['Ford School of Public Policy', 'SCHOOL_PUB_POLICY'],['Law School', 'LAW_SCHOOL'], ['Museum of Art', 'VP_ACAD_GRAD_STUDY'],['Ross School of Business' ,'SCHOOL_BUS_ADMIN'], ['School of Dentistry', 'SCHOOL_DENTISTRY'],['School of Education', 'SCHOOL_EDUCATION'], ['School of Information', 'SCHOOL_INFORMATION'], ['School of Kinesiology', 'SCHOOL_KINESIOLOGY'],['School for Environment and Sustainability','SCHOOL_NAT_RES_ENVIR'],['School of Nursing','SCHOOL_NURSING'], ['School of Music, Theatre and Dance','SCHOOL_MUSIC'], ['School of Public Health', 'SCHOOL_PUB_HEALTH'],['School of Social Work', 'SCHOOL_SOCIAL_WORK']]
end

end
