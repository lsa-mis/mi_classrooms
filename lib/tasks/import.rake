require "csv"
require "benchmark"
require "importers/buildings_importer"
require "importers/rooms_importer"
require "importers/room_characteristics_importer"
# require "importers/room_contacts_importer"

namespace :import do
  desc "Import Buildings from CSV"
  task buildings: :environment do
    time = Benchmark.measure {
      file = Rails.root.join("uploads/buildings.csv")
      BuildingsImporter.new.import(file)
    }
    puts "Buildings Time: #{time}"
  end

  desc "Geocode Buildings"
  task geocode_buildings: :environment do
    time = Benchmark.measure {
      Building.all.each { |b| GeocodeBuildingJob.perform_later(b.bldrecnbr) }
    }
    puts "Buildings Geocoded Time: #{time}"
  end

  desc "Import Rooms from CSV file"
  task rooms: [:environment] do
    time = Benchmark.measure {
      RoomsImporter.new.import_rooms
    }
    puts "Rooms Time: #{time}"
  end

  desc "Import Room Characteristics from CSV file"
  task room_characteristics: [:environment] do
    time = Benchmark.measure {
      RoomCharacteristicsImporter.new
    }
    puts "Room Characteristics Time: #{time}"
  end

  # desc "Import Room Contacts from CSV file"
  # task room_contacts: [:environment] do
  #   time = Benchmark.measure {
  #     RoomContactsImporter.new
  #   }
  #   puts "Room Contacts Time: #{time}"
  # end

  # desc "Import Everything"
  # task all: [:environment] do
  #   time = Benchmark.measure {
  #     BuildingsImporter.new.import("uploads/buildings.csv")
  #     RoomsImporter.new.import_rooms
  #     RoomCharacteristicsImporter.new
  #     RoomContactsImporter.new
  #   }
  #   puts "Everything imported"
  # end
end
