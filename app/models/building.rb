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
  self.primary_key = "bldrecnbr"
  belongs_to :campus_record, optional: true
  has_many :rooms, primary_key: "bldrecnbr", foreign_key: "building_bldrecnbr"
  geocoded_by :address # can also be an IP address
  has_one_attached :building_image
  has_many :floors, primary_key: "bldrecnbr", foreign_key: "building_bldrecnbr"
  has_many :notes, as: :noteable
  has_many :building_hours, primary_key: "bldrecnbr", foreign_key: "building_bldrecnbr"

  validate :acceptable_image

  multisearchable(
    against: [:name, :nick_name, :abbreviation, :bldrecnbr],
    update_if: :updated_at_changed?,
  )

  pg_search_scope(
    :with_name,
    against: {
      nick_name: "A",
      abbreviation: "B",
      name: "C",
    },
    using: {
      tsearch: {
        dictionary: "english",
        prefix: true,
        any_word: false,

      },
    },
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

  def currently_open?
    current_day = Time.zone.now.to_date
    current_day_of_week = Time.zone.now.wday
    current_time = Time.zone.now.seconds_since_midnight.to_i

    # Return false if today is a holiday
    return false if Rails.configuration.holidays.include?(current_day)

    building_hour = BuildingHour.find_by(building_bldrecnbr: self.bldrecnbr, day_of_week: current_day_of_week)

    if building_hour.present?
      open_time = building_hour.open_time
      close_time = building_hour.close_time

      return false if open_time.nil? || close_time.nil?

      open_time <= current_time && current_time <= close_time
    else
      false
    end
  end

  def hours_today
    current_day_of_week = Time.zone.now.wday
    current_day = Time.zone.now.to_date
    building_hour = BuildingHour.find_by(building_bldrecnbr: self.bldrecnbr, day_of_week: current_day_of_week)

    if building_hour && !Rails.configuration.holidays.include?(current_day)
      open_time = Time.at(building_hour.open_time).utc.strftime("%H:%M") if building_hour.open_time
      close_time = Time.at(building_hour.close_time).utc.strftime("%H:%M") if building_hour.close_time
      { open: open_time, close: close_time }
    else
      { open: nil, close: nil }
    end
  end

  def hours_tomorrow
    tomorrow_day_of_week = (Time.zone.now.wday + 1) % 7
    tomorrow_day = Time.zone.now.to_date + 1.day
    building_hour = BuildingHour.find_by(building_bldrecnbr: self.bldrecnbr, day_of_week: tomorrow_day_of_week)

    if building_hour && !Rails.configuration.holidays.include?(tomorrow_day)
      open_time = Time.at(building_hour.open_time).utc.strftime("%H:%M") if building_hour.open_time
      close_time = Time.at(building_hour.close_time).utc.strftime("%H:%M") if building_hour.close_time
      { open: open_time, close: close_time }
    else
      { open: nil, close: nil }
    end
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
