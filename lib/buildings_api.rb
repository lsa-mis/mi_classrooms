class BuildingsApi
  REMOVE_BLDG_IDS = [1000890].freeze
  CAMPUS_CODES = [100].freeze
  BUILDINGS_CODES = [1000440, 1000234, 1000204, 1000333, 1005224, 1005059, 1005347].freeze

  def initialize(access_token)
    @access_token = access_token
    @debug = false
    @logger = ApiLog.instance.logger
  end

  def update_campus_list
    result = api_get("https://gw.api.it.umich.edu/um/bf/Campuses")
    return log_error(result['error']) unless result['success']

    ActiveRecord::Base.transaction do
      update_or_create_campuses(result['Campuses']['Campus'])
      # delete_unused_campuses
    end
    @debug
  end

  def update_all_buildings
    result = api_get("https://gw.api.it.umich.edu/um/bf/BuildingInfo")
    return log_error(result['error']) unless result['success']

    ActiveRecord::Base.transaction do
      update_or_create_buildings(result['ListOfBldgs']['Buildings'])
    end
    @debug
  end

  private

  def api_get(url)
    uri = URI(url)
    request = Net::HTTP::Get.new(uri)
    request["x-ibm-client-id"] = Rails.application.credentials.um_api[:buildings_client_id]
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(request)
    end

    JSON.parse(response.body).tap do |json|
      return {'success' => false, 'error' => json['errorMessage']} if json['errorCode'].present?
    end.merge('success' => true)
  rescue StandardError => e
    {'success' => false, 'error' => e.message}
  end

  def update_or_create_campuses(campuses)
    campuses.each do |campus_data|
      campus_cd = campus_data['CampusCd']
      campus = CampusRecord.find_or_initialize_by(campus_cd: campus_cd)
      unless campus.update(campus_description: campus_data['CampusDescr'])
        log_error("Could not update campus #{campus_cd}: #{campus.errors.full_messages.join(', ')}")
        raise ActiveRecord::Rollback
      end
    end
  end

  # def delete_unused_campuses
  #   puts "campus_cds: #{@campus_cds}"
  #   unused_cds = CampusRecord.pluck(:campus_cd) - @campus_cds
  #   CampusRecord.where(campus_cd: unused_cds).destroy_all
  #   @logger.info "Deleted unused campuses: #{unused_cds.join(', ')}" if unused_cds.any?
  # end

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
  end

  def relevant_building?(building_data)
    CAMPUS_CODES.include?(building_data['BuildingCampusCode'].to_i) || BUILDINGS_CODES.include?(building_data['BuildingRecordNumber'].to_i)
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

  def log_error(message)
    @logger.debug(message)
    @debug = true
  end
  
  def update_rooms
    Building.find_each do |building|
      update_rooms_for_building(building)
    end
    @debug
  rescue StandardError => e
    log_error("update_rooms, error: #{e.message}")
    @debug = true
  end

  def update_rooms_for_building(building)
    dept_auth_token = AuthTokenApi.new("department").get_auth_token
    return log_error("Could not get access_token for DepartmentApi") unless dept_auth_token['success']

    dept_access_token = dept_auth_token['access_token']
    rooms_data = get_building_classroom_data(building.bldrecnbr)
    return log_error(rooms_data['error']) unless rooms_data['success']

    rooms_data['data'].each do |room_data|
      next unless room_data['RoomTypeDescription'] == "Classroom"
      process_room_data(room_data, building, dept_access_token)
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

  def room_attributes(room_data, building, dept_data)
    # Implement logic to return a hash of room attributes for updating/creating a room
    # This will include logic similar to existing update_room and create_room methods
  end

  def cleanup_unused_rooms(building)
    # Implement logic to delete rooms that are no longer present in the API data
  end

  def log_error(message)
    @logger.debug(message)
    @debug = true
  end
end
