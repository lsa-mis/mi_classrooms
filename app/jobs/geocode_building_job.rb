class GeocodeBuildingJob < ApplicationJob

  queue_as :default

  def perform(building)
    address = [building.address, building.city, building.zip].join(" ")
    latitude, longitude = Geocoder.coordinates(address)
    building.update!(latitude: latitude, longitude: longitude)
  end
end
