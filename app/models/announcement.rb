class Announcement < ApplicationRecord
  LOCATIONS = %w[home_page find_a_room_page about_page].freeze

  has_rich_text :content

  validates :location, presence: true, inclusion: { in: LOCATIONS }
end
