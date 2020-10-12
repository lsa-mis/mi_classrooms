class GeocodeBuildingJob < ApplicationJob
  sidekiq_options retry: 5
  queue_as :default

  def perform(bldrecnbr)
    building = Building.find(bldrecnbr)
    address = [building.address, building.city, building.zip].join(" ")
    latitude, longitude = Geocoder.coordinates(address)
    building.update!(latitude: latitude, longitude: longitude)
  end
end
