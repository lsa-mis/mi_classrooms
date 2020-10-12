require "csv"
require "benchmark"

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

class BuildingsImporter
  def initialize
    @bldrecnbrs = Building.all.pluck(:bldrecnbr)
    # import(find_file('uploads/buildings.csv'))
  end

  def building_logger
    @@building_logger ||= Logger.new("#{Rails.root}/log/building_importer.log")
  end

  def building_exists?(bldrecnbr)
    @bldrecnbrs.include?(bldrecnbr.to_i)
  end

  def import(file)
    CSV.foreach(file, headers: true,
                      converters: [:blank_to_nil]) do |row|
      # @building = find_building(row['BLDRECNBR'])
      if building_exists?(row["BLDRECNBR"].to_i)
        update_building(row)
      else
        # create_building(row) if row['BLDPHASE_DESCRSHORT'].strip == 'In Service'
        create_building(row)
      end
    end
  end

  def update_geocoding(building)
    if building.address != "#{row["BLDSTREETNBR"]}  #{row["BLDSTREETDIR"]}  #{row["BLDSTREETNAME"]}".gsub(/\s+/, " ")
      GeocodeBuildingJob.perform_later(@building.id)
    end
  end

  def geocode_buildings
    Building.find_each { |b| GeocodeBuildingJob.perform_later(b.id) }
  end

  def update_building(row)
    @building = Building.find_by(bldrecnbr: row["BLDRECNBR"].to_i)
    if @building.update(bldrecnbr: row["BLDRECNBR"], name: row["BLD_DESCR50"], nick_name: row["BLD_DESCR"], abbreviation: row["BLD_DESCRSHORT"], address: " #{row["BLDSTREETNBR"]}  #{row["BLDSTREETDIR"]}  #{row["BLDSTREETNAME"]}".strip.gsub(/\s+/, " "), city: row["BLDCITY"], state: row["BLDSTATE"], zip: row["BLDPOSTAL"], country: row["BLDCOUNTRY"])
      # puts "UPDATED #{row['BLDRECNBR']}"
      GeocodeBuildingJob.perform_later(@building.id)
    end
  end

  def create_building(row)
    @building = Building.new(id: row["BLDRECNBR"], bldrecnbr: row["BLDRECNBR"], name: row["BLD_DESCR50"], nick_name: row["BLD_DESCR"], abbreviation: row["BLD_DESCRSHORT"], address: "#{row["BLDSTREETNBR"]}  #{row["BLDSTREETDIR"]}  #{row["BLDSTREETNAME"]}".strip.gsub(/\s+/, " "), city: row["BLDCITY"], state: row["BLDSTATE"], zip: row["BLDPOSTAL"], country: row["BLDCOUNTRY"])

    if @building.save
      GeocodeBuildingJob.perform_later(@building.id)
      building_logger.info "Created: #{row["BLDRECNBR"]}"
    else
      building_logger.debug "Could not save #{row["BLDRECNBR"]} because : #{@building.errors.messages}"
    end
  end

  def find_building(row_bldrecnbr)
    Building.find_by(bldrecnbr: row_bldrecnbr) || nil
  end

  def find_file(file)
    Rails.root.join(file)
  end
end
