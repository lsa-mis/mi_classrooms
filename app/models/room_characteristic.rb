# == Schema Information
#
# Table name: room_characteristics
#
#  id                :bigint           not null, primary key
#  chrstc            :integer
#  chrstc_desc254    :string
#  chrstc_descr      :string
#  chrstc_descrshort :string
#  chrstc_eff_status :integer
#  rmrecnbr          :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_room_characteristics_on_rmrecnbr  (rmrecnbr)
#
# Foreign Keys
#
#  fk_rails_...  (rmrecnbr => rooms.rmrecnbr)
#
class RoomCharacteristic < ApplicationRecord
  belongs_to :room, foreign_key: :rmrecnbr, dependent: :destroy

  validates_presence_of :rmrecnbr

  scope :matches_params, ->(params) {
    where(chrstc_descrshort: params).pluck(:rmrecnbr)
    # All of the RoomCharacteristics that have a chrstc_descrshort that matches the params
  }

  def self.has_all_characteristics(params)
    # Give me all of the rmrecnbrs from the room_characteristics that have a chrstc_descrshort that is in the params.
    rmrecnbrs = matches_params(params)
    rmrecnbrs = rmrecnbrs.uniq.map { |t| [t, rmrecnbrs.count(t)] }.to_h
    rmrecnbrs = rmrecnbrs.select { |k, v| v == params.count }
    rmrecnbrs.keys
  end

  def self.has_any_characteristics(params)
    rmrecnbrs = matches_params(params)
  end

  scope :bluray, -> {
                       where(chrstc_descrshort: ["BluRay", "BluRay/DVD"])
                     }
  scope :chalkboard, -> {
                       where(chrstc_descrshort: ["Chkbrd>25", "Chkbrd"])
                     }
  scope :doccam, -> {
                   where(chrstc_descrshort: ["DocCam"])
                 }
  scope :interactive_screen, -> {
                               where(chrstc_descrshort: ["IntrScreen"])
                             }
  scope :instructor_computer, -> {
                                where(chrstc_descrshort: ["InstrComp", "CompPodPC", "CompPodMac"])
                              }
  scope :lecture_capture, -> {
                            where(chrstc_descrshort: ["LectureCap"])
                          }
  scope :projector_16mm, -> {
                           where(chrstc_descrshort: ["Proj16mm"])
                         }
  scope :projector_35mm, -> {
                           where(chrstc_descrshort: ["Proj35mm"])
                         }
  scope :projector_digital_cinema, -> {
                                     where(chrstc_descrshort: ["ProjD-Cin"])
                                   }
  scope :projector_digial, -> {
                             where(chrstc_descrshort: ["ProjDigit"])
                           }
  scope :projector_slide, -> {
                            where(chrstc_descrshort: ["ProjSlide"])
                          }
  scope :team_board, -> {
                       where(chrstc_descrshort: ["TeamBoard"])
                     }
  scope :team_tables, -> {
                        where(chrstc_descrshort: ["TeamTables"])
                      }
  scope :team_technology, -> {
                            where(chrstc_descrshort: ["TeamTech"])
                          }
  scope :vcr, -> {
                where(chrstc_descrshort: ["VCR"])
              }
  scope :video_conf, -> {
                       where(chrstc_descrshort: ["VideoConf"])
                     }
  scope :whiteboard, -> {
                       where(chrstc_descrshort: ["Whtbrd>25", "Whtbrd"])
                     }

  def feature?
    amenities = ["AssistLis", "Blackout", "DocCam", "Ethernet", "EthrStud", "IntrScreen", "LectureCap", "VideoConf", "VCR"]
    if amenities.include?(chrstc_descrshort)
      self
    end
  end

  def chalkboard_feature?
    chalkboards = ["Chkbrd", "Chkbrd>25"]
    if chalkboards.include?(chrstc_descrshort)
      self
    end
  end

  def teamboard_feature?
    teamboards = ["TeamBoard"]
    if teamboards.include?(chrstc_descrshort)
      self
    end
  end

  def teamlearning_feature?
    teamlearning = ["TeamBoard", "TeamTables", "TeamTech"]
    if teamlearning.include?(chrstc_descrshort)
      self
    end
  end

  def instructor_computer?
    amenities = ["InstrComp", "CompPodPC", "CompPodMac"]
    if amenities.include?(chrstc_descrshort)
      self
    end
  end

  def ethernet?
    ethernet = ["Proj16mm", "Proj35mm", "ProjD-Cin", "ProjDigit", "ProjSlide"]
    if ethernet.include?(chrstc_descrshort)

    end
  end

  def projection_feature?
    projectors = ["Proj16mm", "Proj35mm", "ProjD-Cin", "ProjDigit", "ProjSlide"]
    if projectors.include?(chrstc_descrshort)
      self
    end
  end

  def whiteboard_feature?
    whiteboards = ["Whtbrd", "Whtbrd>25"]
    if whiteboards.include?(chrstc_descrshort)
      self
    end
  end
end
