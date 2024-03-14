# class BuildingsApi

#   REMOVE_BLDG = [1000890]
#   CAMPUS_CODES = [100]

#   # include buildings that are not in the campuses described by CAMPUS_CODES
#   # "BuildingRecordNumber": 1000440, "BuildingLongDescription": "MOORE EARL V BLDG", 
#   # "BuildingRecordNumber": 1000234, "BuildingLongDescription": "FRANCIS THOMAS JR PUBLIC HEALTH",
#   # "BuildingRecordNumber": 1000204, "BuildingLongDescription": "VAUGHAN HENRY FRIEZE PUBLIC HEALTH BUILDING",
#   # "BuildingRecordNumber": 1000333, "BuildingLongDescription": "400 NORTH INGALLS BUILDING",
#   # "BuildingRecordNumber": 1005224, "BuildingLongDescription": "STAMPS AUDITORIUM",
#   # "BuildingRecordNumber": 1005059, "BuildingLongDescription": "WALGREEN CHARLES R JR DRAMA CENTER",
#   BUILDINGS_CODES = [1000440, 1000234, 1000204, 1000333, 1005224, 1005059, 1005347]

#   def initialize(access_token)
#     @access_token = access_token
#     @debug = false
#     @log = ApiLog.new
#   end

#   # updates campus list

#   def update_campus_list
#     @campus_cds = CampusRecord.all.pluck(:campus_cd)
#     result = get_campuses
#     if result['success']
#       data = result['data']['Campus']
#       data.each do |row|
#         campus_cd = row['CampusCd']
#         if campus_exists?(row['CampusCd'])
#           update_campus(row)
#         else
#           create_campus(row)
#         end
#         return @debug if @debug
#       end
#       # check if database has information that is not in API anymore
#       if @campus_cds.present?
#         if CampusRecord.where(campus_cd: @campus_cds).destroy_all
#           @log.api_logger.info "update_campus_list, delete #{@campus_cds} campus(es) from the database"
#         else
#           @log.api_logger.debug "update_campus_list, error: could not delete records with #{@campus_cds} ids"
#           @debug = true
#           return @debug
#         end
#       end
#     else
#       @log.api_logger.debug "update_campus_list, error: API return: #{result['errorcode']} - #{result['error']}"
#       @debug = true
#       return @debug
#     end
#     return @debug
#   end

#   def campus_exists?(campus_cd)
#     @campus_cds.include?(campus_cd)
#   end

#   def update_campus(row)
#     campus = CampusRecord.find_by(campus_cd: row['CampusCd'])

#     if campus.update(campus_description: row['CampusDescr'])
#       @campus_cds.delete(row['CampusCd'])
#     else
#       @log.api_logger.debug "update_campus_list, error: Could not update #{row['CampusCd']} because #{campus.errors.messages}"
#       @debug = true
#       return @debug
#     end
#   end

#   def create_campus(row)
#     campus = CampusRecord.new(campus_cd: row['CampusCd'], campus_description: row['CampusDescr'])

#     unless campus.save
#       @log.api_logger.debug "update_campus_list, error: Could not create #{row['CampusCd']} because #{campus.errors.messages}"
#       @debug = true
#       return @debug
#     end
#   end

#   def get_campuses
#     result = {'success' => false, 'errorcode' => '', 'error' => '', 'data' => {}}
#     url = URI("https://gw.api.it.umich.edu/um/bf/Campuses")
#     http = Net::HTTP.new(url.host, url.port)
#     http.use_ssl = true
#     http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#     request = Net::HTTP::Get.new(url)
#     request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
#     request["authorization"] = "Bearer #{@access_token}"
#     request["accept"] = 'application/json'

#     response = http.request(request)
#     response_json = JSON.parse(response.read_body)
#     if response_json['errorCode'].present?
#       result['errorcode'] = response_json['errorCode']
#       result['error'] = response_json['errorMessage']
#     else
#       result['success'] = true
#       result['data'] = response_json['Campuses']
#     end
#     return result
#   end

#   # update buildings

#   def update_all_buildings
#     @buildings_ids = Building.all.pluck(:bldrecnbr)

#     result = get_buildings_for_current_fiscal_year
#     if result['success']
#       data = result['data']
#       data.each do |row|
#         if REMOVE_BLDG.include?(row['BuildingRecordNumber'])
#           next
#         end
#         if CAMPUS_CODES.include?(row['BuildingCampusCode']) || BUILDINGS_CODES.include?(row['BuildingRecordNumber'])
#           if building_exists?(row['BuildingRecordNumber'])
#             update_building(row)
#           else
#             create_building(row)
#           end
#           return @debug if @debug
#         end
#       end

#       # check if there are buildings in the db that were not updated by API
#       if @buildings_ids.present?
#         @log.api_logger.info "update_all_buildings: Building(s) not in the API database: #{@buildings_ids}"
#       end

#     else
#       @log.api_logger.debug "update_all_buildings, error: API return: #{result['errorcode']} - #{result['error']}"
#       @debug = true
#       return @debug
#     end
#     return @debug
#   end

#   def building_exists?(bldrecnbr)
#     @buildings_ids.include?(bldrecnbr)
#   end

#   def update_building(row)
#     building = Building.find_by(bldrecnbr: row['BuildingRecordNumber'])
#     if building.update(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
#           address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
#           city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'usa again', 
#           campus_record_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)
#       @buildings_ids.delete(row['BuildingRecordNumber'])
#     else
#       @log.api_logger.debug "update_all_buildings, error: Could not update #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
#       @debug = true
#       return @debug
#     end
#   end

#   def create_building(row)
#     building = Building.new(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
#         address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
#         city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'USA',
#         campus_record_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)

#     if building.save
#       GeocodeBuildingJob.perform_later(building)
#     else
#       @log.api_logger.debug "update_all_buildings, error: Could not create #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
#       @debug = true
#       return @debug
#     end
#   end

#   def get_buildings_for_current_fiscal_year
#     result = {'success' => false, 'errorcode' => '', 'error' => '', 'data' => {}}
#     url = URI("https://gw.api.it.umich.edu/um/bf/BuildingInfo")
#     http = Net::HTTP.new(url.host, url.port)
#     http.use_ssl = true
#     http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#     request = Net::HTTP::Get.new(url)
#     request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
#     request["authorization"] = "Bearer #{@access_token}"
#     request["accept"] = 'application/json'

#     response = http.request(request)
#     response_json = JSON.parse(response.read_body)
#     if response_json['errorCode'].present?
#       result['errorcode'] = response_json['errorCode']
#       result['error'] = response_json['errorMessage']
#     else
#       result['success'] = true
#       result['data'] = response_json['ListOfBldgs']['Buildings']
#     end
#     return result

#   end

class BuildingsApi
  REMOVE_BLDG_IDS = [1000890].freeze
  CAMPUS_CODES = [100].freeze
  BUILDINGS_CODES = [1000440, 1000234, 1000204, 1000333, 1005224, 1005059, 1005347].freeze

  def initialize(access_token)
    @access_token = access_token
    @debug = false
    @logger = ApiLog.new.logger
  end

  def update_campus_list
    result = api_get("https://gw.api.it.umich.edu/um/bf/Campuses")
    return log_error(result['error']) unless result['success']

    ActiveRecord::Base.transaction do
      update_or_create_campuses(result['data']['Campus'])
      delete_unused_campuses
    end
    @debug
  end

  def update_all_buildings
    result = api_get("https://gw.api.it.umich.edu/um/bf/BuildingInfo")
    return log_error(result['error']) unless result['success']

    ActiveRecord::Base.transaction do
      update_or_create_buildings(result['data']['ListOfBldgs']['Buildings'])
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

  def delete_unused_campuses
    unused_cds = CampusRecord.pluck(:campus_cd) - @campus_cds
    CampusRecord.where(campus_cd: unused_cds).destroy_all
    @logger.info "Deleted unused campuses: #{unused_cds.join(', ')}" if unused_cds.any?
  end

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
end


  # update rooms for every building

  # def update_rooms
  #   begin
  #     @buildings_ids = Building.all.pluck(:bldrecnbr)
  #     dept_auth_token = AuthTokenApi.new("department")
  #     dept_auth_token_result = dept_auth_token.get_auth_token
  #     if dept_auth_token_result['success']
  #       dept_access_token = dept_auth_token_result['access_token']
  #     else
  #       @log.api_logger.debug "update_rooms, error: Could not get access_token for DepartmentApi: #{dept_auth_token_result['error']}"
  #       @debug = true
  #       return @debug
  #     end
  #     dept_info_array = {}
  #     number_of_api_calls_per_minutes = 0
  #     @buildings_ids.each do |bld|
  #       @rooms_in_db = Room.where(building_bldrecnbr: bld).where(rmtyp_description: "Classroom").pluck(:rmrecnbr)
  #       @campus_id = Building.find_by(bldrecnbr: bld).campus_record_id
  #       @building_name = Building.find_by(bldrecnbr: bld).name
  #       result = get_building_classroom_data(bld)
  #       if result['success']
  #         if result['data'].present?
  #           data = result['data']
  #           if data.present?
  #             # check data for buildings that have rooms with RoomTypeDescription == "Classroom"
  #             if data.pluck("RoomTypeDescription").uniq.include?("Classroom")
  #               data.each do |row|
  #                 # update only Classrooms not all rooms
  #                 if row['RoomTypeDescription'] == "Classroom"
  #                   # get information about department
  #                   dept_name = row['DepartmentName']
  #                   if dept_info_array[dept_name].present?
  #                     dept_data = dept_info_array[dept_name]
  #                   else
  #                     # get data from API
  #                     if number_of_api_calls_per_minutes < 400
  #                       number_of_api_calls_per_minutes += 1
  #                     else
  #                       number_of_api_calls_per_minutes = 1
  #                       sleep(61.seconds)
  #                     end
  #                     dept_result = DepartmentApi.new(dept_access_token).get_departments_info(dept_name)
  #                     if dept_result['success']
  #                       if dept_result['data']['DeptData'].present?
  #                         dept_data_info = dept_result['data']['DeptData'][0]
  #                         dept_info_array[dept_name] = 
  #                                                 {'DeptId' => dept_data_info['DeptId'], 
  #                                                 'DeptGroup' => dept_data_info['DeptGroup'], 
  #                                                 'DeptGroupDescription' => dept_data_info['DeptGroupDescription']
  #                                                 }
  #                         dept_data = dept_info_array[dept_name]
  #                       else
  #                         dept_data = nil
  #                       end
  #                     else
  #                       # don't want to interrupt because of Department API errors - just log them 
  #                       @log.api_logger.debug "update_rooms, error: DepartmentApi: Error for building #{bld}, room #{row['RoomRecordNumber']}, department #{dept_name} - #{dept_result['errorcode']}: #{dept_result['error']}"
  #                       dept_data = nil
  #                     end
  #                   end
  #                   if room_exists?(bld, row['RoomRecordNumber'])
  #                     update_room(row, bld, dept_data)
  #                   else
  #                     create_room(row, bld, dept_data)
  #                   end
  #                   # if update_room or create_room returns true (@debug)
  #                   return @debug if @debug
  #                 end
  #               end
  #             end
  #           end
  #         end
  #         # check if database has rooms that are not in API anymore
  #         if @rooms_in_db.present?
  #           RoomContact.where(rmrecnbr: @rooms_in_db).delete_all
  #           RoomCharacteristic.where(rmrecnbr: @rooms_in_db).delete_all
  #           if Room.where(rmrecnbr: @rooms_in_db).delete_all
  #             @log.api_logger.info "update_rooms, delete #{@rooms_in_db} room(s) from the database"
  #           else
  #             @log.api_logger.debug "update_rooms, error: could not delete records with #{@rooms_in_db} rmrecnbr"
  #             @debug = true
  #             return @debug
  #           end
  #         end
  #       else
  #         @log.api_logger.debug "update_rooms, error: API return: #{result['errorcode']} - #{result['error']}"
  #         @debug = true
  #         return @debug
  #       end
  #     end
  #   rescue StandardError => e
  #     # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
  #     @log.api_logger.debug "update_rooms, error: API return: #{e.message}"
  #     @debug = true
  #   end
  #   return @debug
  # end

  # def room_exists?(bldrecnbr, rmrecnbr)
  #   Building.find_by(bldrecnbr: bldrecnbr).rooms.find_by(rmrecnbr: rmrecnbr).present?
  # end

  # def update_room(row, bld, dept_data)
  #   room = Room.find_by(rmrecnbr: row['RoomRecordNumber'])
  #   if dept_data.nil?
  #     if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
  #       square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
  #       dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
  #       campus_record_id: @campus_id, building_name: @building_name)
  #       @rooms_in_db.delete(row['RoomRecordNumber'])
  #     else
  #       @log.api_logger.debug "update_rooms, error: Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
  #       @debug = true
  #       return @debug
  #     end
  #   else
  #     if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
  #             square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
  #             dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
  #             dept_id: dept_data['DeptId'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'],
  #             campus_record_id: @campus_id, building_name: @building_name)
  #       @rooms_in_db.delete(row['RoomRecordNumber'])
  #     else
  #       @log.api_logger.debug "update_rooms, error: Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
  #       @debug = true
  #       return @debug
  #     end
  #   end
  # end

  # def create_room(row, bld, dept_data)
  #   if dept_data.nil?
  #     room = Room.new(building_bldrecnbr: bld, rmrecnbr: row['RoomRecordNumber'], floor: row['FloorNumber'], room_number: row['RoomNumber'], 
  #           square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
  #           dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
  #           campus_record_id: @campus_id, building_name: @building_name, visible: true)
  #   else
  #     room = Room.new(building_bldrecnbr: bld, rmrecnbr: row['RoomRecordNumber'], floor: row['FloorNumber'], room_number: row['RoomNumber'], 
  #           square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
  #           dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
  #           dept_id: dept_data['DeptId'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'],
  #           campus_record_id: @campus_id, building_name: @building_name, visible: true)
  #   end
  #   unless room.save
  #     @log.api_logger.debug "update_rooms, error: Could not create #{row['RoomRecordNumber']} because : #{room.errors.messages}"
  #     @debug = true
  #     return @debug
  #   end
  # end

  # def get_building_classroom_data(bldrecnbr)
  #   result = {'success' => false, 'errorcode' => '', 'error' => '', 'data' => {}}
  #   @debug = false

  #   url = URI("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")
  #   http = Net::HTTP.new(url.host, url.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #   request = Net::HTTP::Get.new(url)
  #   request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
  #   request["authorization"] = "Bearer #{@access_token}"
  #   request["accept"] = 'application/json'

  #   response = http.request(request)
  #   response_json = JSON.parse(response.read_body)
  #   if response_json['errorCode'].present?
  #     result['errorcode'] = response_json['errorCode']
  #     result['error'] = response_json['errorMessage']
  #   else
  #     result['success'] = true
  #     building_data = []
  #     if response_json['ListOfRooms'].nil?
  #       result['data'] = nil
  #     else
  #       data = response_json['ListOfRooms']['RoomData']
  #       if data.is_a?(Hash) 
  #         data = []
  #         data << response_json['ListOfRooms']['RoomData']
  #       end
  #       result['data'] = data
  #     end
  #   end
  #   return result

  # end
  
# end

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
