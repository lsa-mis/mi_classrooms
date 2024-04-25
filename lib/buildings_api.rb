require 'uri'
require 'net/http'
require 'json'
require 'openssl'

class BuildingsApi
  REMOVE_BLDG_IDS = [1000890].freeze
  MCLASSROOMS_CAMPUS_CODES = [100, 300, 500].freeze
  BUILDINGS_CODES = [1000440, 1000234, 1000204, 1000333, 1005224, 1005059, 1005347].freeze

  def initialize(access_token)
    @access_token = access_token
    @debug = false
    @logger = ApiLog.instance.logger
    @buildings_ids = [1005451]# Building.pluck(:bldrecnbr)
    # @dept_access_token = fetch_dept_access_token
    @dept_info_cache = {}
  end

  def update_campus_list
    # result = api_get("https://gw.api.it.umich.edu/um/bf/Campuses")
    result = api_get("https://gw.api.it.umich.edu/um/bf/Buildings/v2/Campuses")
    return log_error(result['error']) unless result['success']

    # puts"BuildingsApi::update_campus_list #{result}"

    ActiveRecord::Base.transaction do
      update_or_create_campuses(result['Campuses']['Campus'])
      delete_unused_campuses(result['Campuses']['Campus'])
    end
    @debug
  end

  def update_all_buildings
    # result = api_get("https://gw.api.it.umich.edu/um/bf/BuildingInfo")
    result = api_get("https://gw.api.it.umich.edu/um/bf/Buildings/v2/BuildingInfo")
    return log_error(result['error']) unless result['success']

    # puts"BuildingsApi::update_all_buildings #{result}"

    ActiveRecord::Base.transaction do
      update_or_create_buildings(result['ListOfBldgs']['Buildings'])
    end
    @debug
  end

  # def update_rooms
  #   # return @debug unless @dept_access_token

  #   @buildings_ids.each do |building_id|
  #     update_rooms_in_building(building_id)
  #   rescue StandardError => e
  #     log_error("API return: #{e.message}")
  #   end
  # end

  def update_all_rooms
    @buildings_ids.each do |building_id|
    # result = api_get("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{building_id}")
    result = api_get("https://gw.api.it.umich.edu/um/bf/Buildings/v2/RoomInfo/#{building_id}")
    return log_error(result['error']) unless result['success']

    # puts"BuildingsApi::update_all_rooms #{result['ListOfRooms']['RoomData']}"
      building = Building.find_by(bldrecnbr: building_id)
      ActiveRecord::Base.transaction do
        update_or_create_rooms(result['ListOfRooms']['RoomData'], building)
      end
    end
    @debug
  end

  private

  def api_get(uri)
    uri = URI(uri)
    request = Net::HTTP::Get.new(uri)
    request["x-ibm-client-id"] = Rails.application.credentials.um_api[:buildings_client_id]
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'
  
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end
  
    # Handle specific error types
    raise "HTTP Error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
  
    json = JSON.parse(response.body)
    
    if json['errorCode'].present?
      return {'success' => false, 'error' => json['errorMessage']}
    else
      return {'success' => true}.merge(json)
    end
  rescue JSON::ParserError => e
    {'success' => false, 'error' => "JSON parsing error: #{e.message}"}
  rescue StandardError => e
    {'success' => false, 'error' => "Unexpected error: #{e.message}"}
  end

  # Logs errors to a log file or standard error.
  def log_error(message)
    @logger.debug(message)
    @debug = true
  end
  # ==============================

  # def fetch_classroom_data(bldrecnbr)
  #   uri = URI("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")


  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true

  #   request = Net::HTTP::Get.new(uri)
  #   request["x-ibm-client-id"] = Rails.application.credentials.um_api[:buildings_client_id].to_s
  #   request["authorization"] = "Bearer #{@access_token}"
  #   request["accept"] = 'application/json'

  #   response = http.request(request)
  #   JSON.parse(response.body)
  # end

  
# ====update_campus_list==========================
  def update_or_create_campuses(campuses)
    # puts "**** update_or_create_campuses #{campuses}"
    campuses.each do |campus_data|
      campus_cd = campus_data['CampusCd']
      campus = CampusRecord.find_or_initialize_by(campus_cd: campus_cd)
      unless campus.update(campus_description: campus_data['CampusDescr'])
        log_error("Could not update campus #{campus_cd}: #{campus.errors.full_messages.join(', ')}")
        raise ActiveRecord::Rollback
      end
    end
    @logger.info "update_or_create_campuses"
  end

  def delete_unused_campuses(campuses)
    campus_codes = MCLASSROOMS_CAMPUS_CODES
    unused_codes = CampusRecord.pluck(:campus_cd) - campus_codes
    CampusRecord.where(campus_cd: unused_codes).destroy_all
    @logger.info "Deleted unused campuses: #{unused_codes.join(', ')}" if unused_codes.any?
  end

  # ====update_all_buildings==========================
  def update_or_create_buildings(buildings)
    buildings.each do |building_data|
      next if REMOVE_BLDG_IDS.include?(building_data['BuildingRecordNumber'].to_i)
      next unless relevant_building?(building_data)

      building = Building.find_or_initialize_by(bldrecnbr: building_data['BuildingRecordNumber'])
      unless building.update(building_attributes(building_data))
        log_error("Could not update building #{building.bldrecnbr}: #{building.errors.full_messages.join(', ')}")
        raise ActiveRecord::Rollback
      end
      GeocodeBuildingJob.perform_later(building.id) if building.persisted?
    end
    @logger.info "update_or_create_buildings"
  end

  def relevant_building?(building_data)
    MCLASSROOMS_CAMPUS_CODES.include?(building_data['BuildingCampusCode'].to_i) || BUILDINGS_CODES.include?(building_data['BuildingRecordNumber'].to_i)
  end

  def building_attributes(data)
    {
      name: data['BuildingLongDescription'],
      abbreviation: data['BuildingShortDescription'],
      address: format_address(data),
      city: data['BuildingCity'],
      state: data['BuildingState'],
      zip: data['BuildingPostal'],
      country: 'USA',
      campus_record_id: CampusRecord.find_by(campus_cd: data['BuildingCampusCode'])&.id
    }
  end

  def format_address(data)
    "#{data['BuildingStreetNumber']} #{data['BuildingStreetDirection']} #{data['BuildingStreetName']}".strip.gsub(/\s+/, " ")
  end

  def update_or_create_rooms(rooms, building_id)
    rooms.each do |room_data|
      next unless room_data['RoomTypeDescription'] == "Classroom"

       puts "BuildingsApi::update_or_create_rooms #{room_data}"

      room = Room.find_or_initialize_by(rmrecnbr: room_data['RoomRecordNumber'])
      unless room.update(room_attributes(room_data, building_id))
        log_error("Could not updateroom #{room.rmrecnbr}: #{room.errors.full_messages.join(', ')}")
        raise ActiveRecord::Rollback
      end
    end
    @logger.info "update_or_create_rooms"
  end

  def room_attributes(data, building)
    {
      floor: data['FloorNumber'],
      room_number: data['RoomNumber'],
      square_feet: data['RoomSquareFeet'],
      rmtyp_description: data['RoomTypeDescription'],
      dept_description: data['DepartmentName'],
      instructional_seating_count: data['RoomStationCount'],
      dept_group_description: data['DepartmentName'],
      building_bldrecnbr: building.id,
      campus_record_id: building.campus_record_id,
      visible: true,
      building_name: building.name,

    }
  end




  def update_rooms_for_building(building,rooms)
    dept_auth_token = AuthTokenApi.new("department").get_auth_token
    return log_error("Could not get access_token for DepartmentApi") unless dept_auth_token['success']

    @dept_access_token = dept_auth_token['access_token']
    return log_error(rooms_data['error']) unless rooms_data['success']

    rooms.each do |room_data|
      next unless room_data['RoomTypeDescription'] == "Classroom"
      process_room_data(room_data, building, @dept_access_token)
    end
    cleanup_unused_rooms(building)
  end

  def process_room_data(room_data, building, dept_access_token)
    dept_data = get_dept_data(room_data['DepartmentName'], dept_access_token)
    room = Room.find_or_initialize_by(bldrecnbr: building.bldrecnbr, rmrecnbr: room_data['RoomRecordNumber'])
    update_or_create_room(room, room_data, building, dept_data)
  end

  def get_dept_data(dept_name, dept_access_token)
    # Implement logic to fetch department data, similar to existing implementation
    # Consider caching department data to reduce API calls
  end

  def update_or_create_room(room, room_data, building, dept_data)
    room.assign_attributes(room_attributes(room_data, building, dept_data))
    unless room.save
      log_error("Could not save room #{room.rmrecnbr}: #{room.errors.full_messages.join(', ')}")
      @debug = true
    end
  end

  # def room_attributes(room_data, building, dept_data)
  #   # Implement logic to return a hash of room attributes for updating/creating a room
  #   # This will include logic similar to existing update_room and create_room methods
  # end

  def cleanup_unused_rooms(building)
    # Implement logic to delete rooms that are no longer present in the API data
  end

  # def log_error(message)
  #   @logger.debug(message)
  #   @debug = true
  # end

  # def fetch_dept_access_token
  #   dept_auth_token = AuthTokenApi.new("department").get_auth_token
  #   if dept_auth_token['success']
  #     dept_auth_token['access_token']
  #   else
  #     log_error("Could not get access_token for DepartmentApi: #{dept_auth_token['error']}")
  #     nil
  #   end
  # end


    # ====update_rooms==========================
  def update_rooms_in_building(building_id)
    building = Building.find_by(bldrecnbr: building_id)
    return unless building

    classroom_data = get_building_classroom_data(building_id)
    return log_error("API return: #{classroom_data['errorcode']} - #{classroom_data['error']}") unless classroom_data['success']

    classroom_data['data']&.each do |row|
      next unless row['RoomTypeDescription'] == "Classroom"

      dept_data = fetch_or_use_cached_dept_info(row['DepartmentName'])
      room_record_number = row['RoomRecordNumber']
      if room_exists?(building_id, room_record_number)
        update_room(row, building, dept_data)
      else
        create_room(row, building, dept_data)
      end

      break if @debug
    end

    remove_orphan_rooms(building.rooms.pluck(:rmrecnbr), classroom_data['data'].pluck('RoomRecordNumber'))
  end
# =====================================


  def get_building_classroom_data(building_id)
    # result = fetch_classroom_data(bldrecnbr)
    result = api_get("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{building_id}")
    
    format_response(result)
  rescue => e
    log_error("HTTP request failed: #{e.message}")
    { 'success' => false, 'errorcode' => e.class.to_s, 'error' => e.message, 'data' => {} }
  end

  # Fetches classroom data from the external API.
  # def fetch_classroom_data(bldrecnbr)
  #   uri = URI("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true

  #   request = Net::HTTP::Get.new(uri)
  #   request["x-ibm-client-id"] = Rails.application.credentials.um_api[:buildings_client_id].to_s
  #   request["authorization"] = "Bearer #{@access_token}"
  #   request["accept"] = 'application/json'

  #   response = http.request(request)
  #   JSON.parse(response.body)
  # end

  # Formats the API response into a standardized hash format.
  def format_response(response_json)
    if response_json.key?('errorCode')
      { 'success' => false, 'errorcode' => response_json['errorCode'], 'error' => response_json['errorMessage'], 'data' => {} }
    else
      { 'success' => true, 'data' => normalize_data(response_json['ListOfRooms']['RoomData']) }
    end
  end

  # Normalizes data to ensure it's always returned as an array.
  def normalize_data(data)
    return [] if data.nil?
    data.is_a?(Array) ? data : [data]
  end

# Attempts to fetch department information from the cache; if unavailable, fetches from the API.
  def fetch_or_use_cached_dept_info(dept_name)
    return @dept_info_cache[dept_name] if @dept_info_cache.key?(dept_name)

    fetch_dept_info_from_api(dept_name).tap do |dept_data|
      @dept_info_cache[dept_name] = dept_data unless dept_data.nil?
    end
  end

  # Fetches department information from the external API and handles rate limiting.
  def fetch_dept_info_from_api(dept_name)
    rate_limit_api_calls

    dept_result = DepartmentApi.new(@dept_access_token).get_departments_info(dept_name)
    if dept_result['success'] && dept_result['data']['DeptData'].present?
      dept_data_info = dept_result['data']['DeptData'][0]
      {'DeptId' => dept_data_info['DeptId'],
      'DeptGroup' => dept_data_info['DeptGroup'],
      'DeptGroupDescription' => dept_data_info['DeptGroupDescription']}
    else
      log_error("DepartmentApi: Error for department #{dept_name} - #{dept_result['errorcode']}: #{dept_result['error']}")
      nil
    end
  end

  # Implements a simple rate limiter for API calls.
  def rate_limit_api_calls
    @api_calls_counter ||= 0
    @last_api_call_time ||= Time.now

    if @api_calls_counter >= 400
      sleep_time = [61 - (Time.now - @last_api_call_time), 0].max
      sleep(sleep_time) if sleep_time > 0
      @api_calls_counter = 0
    end

    @api_calls_counter += 1
    @last_api_call_time = Time.now
  end

  def room_exists?(building_id, room_record_number)
    Room.exists?(building_bldrecnbr: building_id, rmrecnbr: room_record_number)
  end

  def update_room(row, building, dept_data)
    # Find the room within the given building
    room = building.rooms.find_by(rmrecnbr: row['RoomRecordNumber'])
    
    # Prepare the room attributes for update
    room_attrs = {
      floor: row['FloorNumber'],
      room_number: row['RoomNumber'],
      square_feet: row['RoomSquareFeet'],
      rmtyp_description: row['RoomTypeDescription'],
      dept_description: row['DepartmentName'],
      instructional_seating_count: row['RoomStationCount']
    }
    
    # Add department data if available
    if dept_data.present?
      room_attrs.merge!({
        dept_id: dept_data['DeptId'],
        dept_grp: dept_data['DeptGroup'],
        dept_group_description: dept_data['DeptGroupDescription']
      })
    end
  
    # Attempt to update the room with the new attributes
    if room.update(room_attrs)
      true # Successful update
    else
      # Handle the update failure, possibly logging the errors
      log_error("Could not update room #{room.rmrecnbr}: #{room.errors.full_messages.join(", ")}")
      false # Indicate failure
    end
  end

  def create_room(row, building, dept_data)
    # Construct the new room attributes from the provided data
    room_attrs = {
      building_bldrecnbr: building.bldrecnbr, # Assuming this is the foreign key in the Room model for building
      rmrecnbr: row['RoomRecordNumber'],
      floor: row['FloorNumber'],
      room_number: row['RoomNumber'],
      square_feet: row['RoomSquareFeet'],
      rmtyp_description: row['RoomTypeDescription'],
      dept_description: row['DepartmentName'],
      instructional_seating_count: row['RoomStationCount'],
      campus_record_id: building.campus_record_id, # Assuming the Building model contains campus_record_id
      building_name: building.name, # Assuming the Building model contains name
      visible: true # Assuming new rooms should be visible by default
    }
  
    # Add department data if available
    if dept_data.present?
      room_attrs.merge!({
        dept_id: dept_data['DeptId'],
        dept_grp: dept_data['DeptGroup'],
        dept_group_description: dept_data['DeptGroupDescription']
      })
    end
  
    # Create the new room within the building's context
    room = building.rooms.build(room_attrs)
  
    # Attempt to save the new room
    if room.save
      true # Indicate success
    else
      # Handle failure to save, possibly logging the errors
      log_error("Could not create room #{room_attrs[:rmrecnbr]}: #{room.errors.full_messages.join(", ")}")
      false # Indicate failure
    end
  end

  def remove_orphan_rooms(current_room_numbers, updated_room_numbers)
    # Find orphan room numbers by excluding updated room numbers from the current room numbers
    orphan_room_numbers = current_room_numbers - updated_room_numbers
  
    # Guard clause to skip further processing if there are no orphan rooms
    return if orphan_room_numbers.empty?
  
    # Assuming Room model has 'rmrecnbr' as an attribute to identify rooms
    # Remove rooms identified by orphan_room_numbers
    Room.where(rmrecnbr: orphan_room_numbers).destroy_all
  
    # Logging or any additional steps post deletion
    log_error("Removed orphan rooms with numbers: #{orphan_room_numbers.join(', ')}")
  end

end
