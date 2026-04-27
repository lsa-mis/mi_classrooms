class BuildingsApi
  BASE_URL = "https://gw.api.it.umich.edu/um/bf/Buildings/v2".freeze
  REMOVE_BLDG = ["1000890"].freeze
  CAMPUS_CODES = ["100"].freeze
  NUMBER_OF_API_CALLS = 400

  # include buildings that are not in the campuses described by CAMPUS_CODES
  # "BuildingRecordNumber": 1000440, "BuildingLongDescription": "MOORE EARL V BLDG",
  # "BuildingRecordNumber": 1000234, "BuildingLongDescription": "FRANCIS THOMAS JR PUBLIC HEALTH",
  # "BuildingRecordNumber": 1000204, "BuildingLongDescription": "VAUGHAN HENRY FRIEZE PUBLIC HEALTH BUILDING",
  # "BuildingRecordNumber": 1000333, "BuildingLongDescription": "400 NORTH INGALLS BUILDING",
  # "BuildingRecordNumber": 1005224, "BuildingLongDescription": "STAMPS AUDITORIUM",
  # "BuildingRecordNumber": 1005059, "BuildingLongDescription": "WALGREEN CHARLES R JR DRAMA CENTER",
  BUILDINGS_CODES = ["1000440", "1000234", "1000204", "1000333", "1005224", "1005059", "1005347"].freeze

  attr_reader :last_result

  def initialize(access_token = nil, delete_dry_run: false)
    @client = UmApi::Connection.new(access_token: access_token, scope: "buildings")
    @debug = false
    @log = ApiLog.new
    @delete_dry_run = delete_dry_run
    @last_result = nil
  end

  def update_campus_list
    start_result("Update campus list")
    @campus_cds = CampusRecord.all.pluck(:campus_cd)
    result = get_campuses
    increment(:api_calls)
    if result["success"]
      data = result["data"]["Campus"]
      data.each do |row|
        if campus_exists?(row["CampusCd"])
          update_campus(row)
        else
          create_campus(row)
        end
        return finish_result if @debug
      end

      if @campus_cds.present?
        deleted_count = @campus_cds.count
        if CampusRecord.where(campus_cd: @campus_cds).destroy_all
          increment(:deleted, deleted_count)
          @log.api_logger.info "update_campus_list, delete #{@campus_cds} campus(es) from the database"
        else
          add_error("update_campus_list, error: could not delete records with #{@campus_cds} ids")
          return finish_result
        end
      end
    else
      add_error("update_campus_list, error: API return: #{result["errorcode"]} - #{result["error"]}")
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
      return finish_result
    end

    finish_result
  end

  def campus_exists?(campus_cd)
    @campus_cds.include?(campus_cd.to_i)
  end

  def update_campus(row)
    campus_cd = row["CampusCd"].to_i
    campus = CampusRecord.find_by(campus_cd: campus_cd)

    if campus.update(campus_description: row["CampusDescr"])
      increment(:updated)
      @campus_cds.delete(campus_cd)
    else
      add_error("update_campus_list, error: Could not update #{campus_cd} because #{campus.errors.messages}")
    end
  end

  def create_campus(row)
    campus_cd = row["CampusCd"].to_i
    campus = CampusRecord.new(campus_cd: campus_cd, campus_description: row["CampusDescr"])

    if campus.save
      increment(:created)
    else
      add_error("update_campus_list, error: Could not create #{campus_cd} because #{campus.errors.messages}")
    end
  end

  def get_campuses
    response = @client.get_json("#{BASE_URL}/Campuses")
    return strip_headers(response) unless response["success"]

    success_result(response["data"]["Campuses"])
  end

  def update_all_buildings
    start_result("Update buildings")
    begin
      @buildings_ids = Building.all.pluck(:bldrecnbr)
      result = get_buildings_for_current_fiscal_year
      increment(:api_calls)
      if result["success"]
        result["data"].each do |row|
          if REMOVE_BLDG.include?(row["BuildingRecordNumber"])
            increment(:skipped)
            next
          end
          unless CAMPUS_CODES.include?(row["BuildingCampusCode"]) || BUILDINGS_CODES.include?(row["BuildingRecordNumber"])
            increment(:skipped)
            next
          end

          if building_exists?(row["BuildingRecordNumber"])
            update_building(row)
          else
            create_building(row)
          end
          return finish_result if @debug
        end

        if @buildings_ids.present?
          add_warning("update_all_buildings: Building(s) not in the API database: #{@buildings_ids}")
          @log.api_logger.info "update_all_buildings: Building(s) not in the API database: #{@buildings_ids}"
        end
      else
        add_error("update_all_buildings, error: API return: #{result["errorcode"]} - #{result["error"]}")
        sleep(61.seconds)
        increment(:rate_limit_sleeps)
        return finish_result
      end
    rescue => e
      add_error("update_all_buildings, error: #{e.message}")
    end

    finish_result
  end

  def building_exists?(bldrecnbr)
    @buildings_ids.include?(bldrecnbr.to_i)
  end

  def update_building(row)
    bldrecnbr = row["BuildingRecordNumber"].to_i
    building = Building.find_by(bldrecnbr: bldrecnbr)
    if building.update(
      bldrecnbr: bldrecnbr,
      name: row["BuildingLongDescription"],
      abbreviation: row["BuildingShortDescription"],
      address: " #{row["BuildingStreetNumber"]}  #{row["BuildingStreetDirection"]}  #{row["BuildingStreetName"]}".strip.gsub(/\s+/, " "),
      city: row["BuildingCity"],
      state: row["BuildingState"],
      zip: row["BuildingPostal"],
      country: "USA",
      campus_record_id: CampusRecord.find_by(campus_cd: row["BuildingCampusCode"].to_i).id
    )
      @buildings_ids.delete(bldrecnbr)
      increment(:updated)
    else
      add_error("update_all_buildings, error: Could not update #{bldrecnbr} because : #{building.errors.messages}")
    end
  end

  def create_building(row)
    bldrecnbr = row["BuildingRecordNumber"].to_i
    building = Building.new(
      bldrecnbr: bldrecnbr,
      name: row["BuildingLongDescription"],
      abbreviation: row["BuildingShortDescription"],
      address: " #{row["BuildingStreetNumber"]}  #{row["BuildingStreetDirection"]}  #{row["BuildingStreetName"]}".strip.gsub(/\s+/, " "),
      city: row["BuildingCity"],
      state: row["BuildingState"],
      zip: row["BuildingPostal"],
      country: "USA",
      campus_record_id: CampusRecord.find_by(campus_cd: row["BuildingCampusCode"].to_i).id
    )

    if building.save
      increment(:created)
      GeocodeBuildingJob.perform_later(building)
    else
      add_error("update_all_buildings, error: Could not create #{bldrecnbr} because : #{building.errors.messages}")
    end
  end

  def get_buildings_for_current_fiscal_year
    strip_headers(
      @client.paginated_get(
        "#{BASE_URL}/BuildingInfo",
        collection_path: %w[ListOfBldgs Buildings]
      )
    )
  end

  def update_rooms
    start_result("Update Rooms")
    begin
      @buildings_ids = Building.all.pluck(:bldrecnbr)
      department_api = DepartmentApi.new
      dept_info_array, fallback_department_lookup = preload_departments(department_api)
      number_of_api_calls_per_minutes = 0

      @buildings_ids.each do |bld|
        building = Building.find_by(bldrecnbr: bld)
        next unless building

        @rooms_in_db = Room.where(building_bldrecnbr: bld, rmtyp_description: "Classroom").pluck(:rmrecnbr)
        @campus_id = building.campus_record_id
        @building_name = building.name
        result = get_building_classroom_data(bld)
        increment(:api_calls)
        if result["success"]
          data = result["data"]
          if data.present? && data.pluck("RoomTypeDescription").uniq.include?("Classroom")
            data.each do |row|
              next unless row["RoomTypeDescription"] == "Classroom"

              dept_data, number_of_api_calls_per_minutes = lookup_department_data(
                department_api,
                dept_info_array,
                row["DepartmentName"],
                bld,
                row["RoomRecordNumber"],
                number_of_api_calls_per_minutes,
                fallback_department_lookup
              )

              if room_exists?(bld, row["RoomRecordNumber"])
                update_room(row, bld, dept_data)
              else
                create_room(row, bld, dept_data)
              end
              return finish_result if @debug
            end
          end

          if @rooms_in_db.present?
            if @delete_dry_run
              increment(:would_delete, @rooms_in_db.count)
              add_warning("update_rooms, dry run: would deactivate #{@rooms_in_db} stale room(s)")
            else
              deactivated_count = deactivate_stale_rooms("update_rooms")
              if deactivated_count
                increment(:deactivated, deactivated_count)
                @log.api_logger.info "update_rooms, deactivated #{@rooms_in_db} stale room(s)"
              else
                add_error("update_rooms, error: could not deactivate records with #{@rooms_in_db} rmrecnbr")
                return finish_result
              end
            end
          end
        else
          add_error("update_rooms, error: API return: #{result["errorcode"]} - #{result["error"]}")
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
          return finish_result
        end
      end
    rescue => e
      add_error("update_rooms, error: #{e.message}")
    end

    finish_result
  end

  def room_exists?(bldrecnbr, rmrecnbr)
    Building.find_by(bldrecnbr: bldrecnbr).rooms.find_by(rmrecnbr: rmrecnbr.to_i).present?
  end

  def update_room(row, _bld, dept_data)
    rmrecnbr = row["RoomRecordNumber"].to_i
    room = Room.find_by(rmrecnbr: rmrecnbr)
    if dept_data.nil?
      if room.update(
        floor: row["FloorNumber"],
        room_number: row["RoomNumber"],
        square_feet: row["RoomSquareFeet"],
        rmtyp_description: row["RoomTypeDescription"],
        dept_description: row["DepartmentName"],
        instructional_seating_count: row["RoomStationCount"],
        campus_record_id: @campus_id,
        building_name: @building_name,
        visible: true
      )
        @rooms_in_db.delete(rmrecnbr)
        increment(:updated)
      else
        add_error("update_rooms, error: Could not update #{rmrecnbr} because : #{room.errors.messages}")
      end
    elsif room.update(
      floor: row["FloorNumber"],
      room_number: row["RoomNumber"],
      square_feet: row["RoomSquareFeet"],
      rmtyp_description: row["RoomTypeDescription"],
      dept_description: row["DepartmentName"],
      instructional_seating_count: row["RoomStationCount"],
      dept_id: dept_data["DeptId"],
      dept_grp: dept_data["DeptGroup"],
      dept_group_description: dept_data["DeptGroupDescription"],
      campus_record_id: @campus_id,
      building_name: @building_name,
      visible: true
    )
      @rooms_in_db.delete(rmrecnbr)
      increment(:updated)
    else
      add_error("update_rooms, error: Could not update #{rmrecnbr} because : #{room.errors.messages}")
    end
  end

  def create_room(row, bld, dept_data)
    rmrecnbr = row["RoomRecordNumber"].to_i
    room_attributes = {
      building_bldrecnbr: bld,
      rmrecnbr: rmrecnbr,
      floor: row["FloorNumber"],
      room_number: row["RoomNumber"],
      square_feet: row["RoomSquareFeet"],
      rmtyp_description: row["RoomTypeDescription"],
      dept_description: row["DepartmentName"],
      instructional_seating_count: row["RoomStationCount"],
      campus_record_id: @campus_id,
      building_name: @building_name,
      visible: true
    }
    if dept_data.present?
      room_attributes.merge!(
        dept_id: dept_data["DeptId"],
        dept_grp: dept_data["DeptGroup"],
        dept_group_description: dept_data["DeptGroupDescription"]
      )
    end

    room = Room.new(room_attributes)
    if room.save
      increment(:created)
    else
      add_error("update_rooms, error: Could not create #{rmrecnbr} because : #{room.errors.messages}")
    end
  end

  def get_building_classroom_data(bldrecnbr)
    strip_headers(
      @client.paginated_get(
        "#{BASE_URL}/RoomInfo/#{bldrecnbr}",
        collection_path: %w[ListOfRooms RoomData]
      )
    )
  end

  private

  def preload_departments(department_api)
    result = department_api.get_all_departments_info
    return [build_department_index(result["data"]), false] if result["success"]

    add_warning("update_rooms, error: could not preload departments - #{result["errorcode"]}: #{result["error"]}. Falling back to per-department lookups.")
    [{}, true]
  end

  def build_department_index(departments)
    Array(departments).each_with_object({}) do |department, lookup|
      next if department["DeptDescription"].blank?

      lookup[department["DeptDescription"]] ||= department_summary(department)
    end
  end

  def lookup_department_data(department_api, dept_info_array, dept_name, bld, room_record_number, number_of_api_calls_per_minutes, fallback_department_lookup)
    return [nil, number_of_api_calls_per_minutes] if dept_name.blank?
    return [dept_info_array[dept_name], number_of_api_calls_per_minutes] if dept_info_array.key?(dept_name)
    return [nil, number_of_api_calls_per_minutes] unless fallback_department_lookup

    if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
      number_of_api_calls_per_minutes += 1
    else
      number_of_api_calls_per_minutes = 1
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
    end
    increment(:api_calls)

    dept_result = department_api.get_departments_info(dept_name)
    if dept_result["success"]
      dept_info = dept_result.dig("data", "DeptData", 0)
      dept_info_array[dept_name] = dept_info.present? ? department_summary(dept_info) : nil
    else
      add_warning("update_rooms, error: DepartmentApi: Error for building #{bld}, room #{room_record_number}, department #{dept_name} - #{dept_result["errorcode"]}: #{dept_result["error"]}")
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
      dept_info_array[dept_name] = nil
    end

    [dept_info_array[dept_name], number_of_api_calls_per_minutes]
  end

  def department_summary(dept_data_info)
    {
      "DeptId" => dept_data_info["DeptId"],
      "DeptGroup" => dept_data_info["DeptGroup"],
      "DeptGroupDescription" => dept_data_info["DeptGroupDescription"]
    }
  end

  def success_result(data)
    {"success" => true, "errorcode" => "", "error" => "", "data" => data}
  end

  def strip_headers(result)
    result.except("headers")
  end

  def deactivate_stale_rooms(context)
    room_ids = @rooms_in_db.uniq
    expected_count = room_ids.count
    deactivated_count = 0

    ActiveRecord::Base.transaction do
      deactivated_count = Room.where(rmrecnbr: room_ids).where.not(visible: false).update_all(visible: false)

      if deactivated_count != expected_count
        @log.api_logger.debug "#{context}, error: expected to deactivate #{expected_count} room(s), deactivated #{deactivated_count}"
        raise ActiveRecord::Rollback
      end
    end

    (deactivated_count == expected_count) ? deactivated_count : false
  end

  def start_result(phase)
    @debug = false
    @last_result = ApiUpdateDatabase::PhaseResult.new(phase)
  end

  def finish_result
    @last_result.finish
    @debug
  end

  def increment(counter, by = 1)
    @last_result&.increment(counter, by)
  end

  def add_warning(message)
    @last_result&.add_warning(message)
    @log.api_logger.info message
  end

  def add_error(message)
    @last_result&.add_error(message)
    @log.api_logger.debug message
    @debug = true
  end
end
