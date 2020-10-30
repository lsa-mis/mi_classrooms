require "csv"
require "benchmark"
require "active_record"


CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

class RoomsImporter
  ROOM_PARAMS = [:rmrecnbr, :floor, :room_number, :facility_code_heprod, :rmtyp_description, :dept_id, :dept_grp, :dept_description, :square_feet, :instructional_seating_count, :building_bldrecnbr].freeze

  HEADER_MAP = {
                "RMRECNBR" => :rmrecnbr,
                "DEPTID" => :dept_id,
                "DEPT_DESCR" => :dept_description,
                "DEPT_GRP" => :dept_grp,
                "BLDRECNBR" => :building_bldrecnbr,
                "FLOOR" => :floor,
                "RMNBR" => :room_number,
                "RMSQRFT" => :square_feet,
                "RMTYP_DESCR50" => :rmtyp_description,
                "FACILITY_ID" => :facility_code_heprod,
                "RM_INST_SEAT_CNT" => :instructional_seating_count}.freeze

  def initialize
    puts "Loading buildings..."
    @buildings =  Building.all.uniq.pluck(:bldrecnbr)
    file = Rails.root.join("uploads/rooms.csv")
    puts "Loading rooms from csv file..."
    rooms = load_rooms_from_csv(file)
    import_rooms(rooms)
  end

  def load_rooms_from_csv(file)
    rooms = []
    CSV.foreach(file, headers: true, header_converters: lambda { |header| HEADER_MAP[header] }) do |room|
      if building_exists?(room[:building_bldrecnbr])
        room = create_valid_room(room).to_h
        rooms << room
      end
    end
    rooms
    # puts "After clean: #{rooms.count}"
  end


  def create_valid_room(room)
    room[:instructional_seating_count] = (room[:instructional_seating_count] || 0)
    room[:facility_code_heprod] = facility_code_heprod(room)
    room[:created_at] = Time.now
    room[:updated_at] = Time.now
    room[:visible] = false
    room = room.select {|k, v| !k.blank?}
  end


  def facility_code_heprod(room)
    if room[:facility_code_heprod] == "no match"
      room[:facility_code_heprod] = nil
    else
      room[:facility_code_heprod] = room[:facility_code_heprod]
    end
  end

  def import_rooms(rooms)
    Room.insert_all(rooms)
  end

  ## HELPER METHODS

  def building_exists?(bldrecnbr)
    @buildings.include?(bldrecnbr.to_i)
  end

  def find_file(file)
    Rails.root.join(file)
  end

  def room_logger
    @@room_logger ||= Logger.new("#{Rails.root}/log/room_importer.log")
  end
end
