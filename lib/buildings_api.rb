class BuildingsApi

  REMOVE_BLDG = [1000890]

  def initialize(access_token)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @access_token = access_token
    @debug = false
    @log = ApiLog.new
  end

  # updates campus list

  def update_campus_list
    @campus_cds = CampusRecord.all.pluck(:campus_cd)
    @result = get_campuses
    if @result['success']
      data = @result['data']['Campus']
      data.each do |row|
        campus_cd = row['CampusCd']
        if campus_exists?(row['CampusCd'])
          update_campus(row)
        else
          create_campus(row)
        end
        return @debug if @debug
      end
      # check if database has information that is not in API anymore
      if @campus_cds.present?
        if CampusRecord.where(campus_cd: @campus_cds).destroy_all
          @log.api_logger.info "update_campus_list, delete #{@campus_cds} campus(es) from the database"
        else
          @log.api_logger.debug "update_campus_list, error: could not delete records with #{@campus_cds} ids"
          @debug = true
          return @debug
        end
      end
    else
      @log.api_logger.debug "update_campus_list, error: API return: #{@result['error']}"
      @debug = true
      return @debug
    end
    return @debug
  end

  def campus_exists?(campus_cd)
    @campus_cds.include?(campus_cd)
  end

  def update_campus(row)
    campus = CampusRecord.find_by(campus_cd: row['CampusCd'])

    if campus.update(campus_description: row['CampusDescr'])
      @campus_cds.delete(row['CampusCd'])
    else
      @log.api_logger.debug "update_campus_list, error: Could not update #{row['CampusCd']} because #{campus.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def create_campus(row)
    campus = CampusRecord.new(campus_cd: row['CampusCd'], campus_description: row['CampusDescr'])

    unless campus.save
      @log.api_logger.debug "update_campus_list, error: Could not create #{row['CampusCd']} because #{campus.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def get_campuses 
    url = URI("https://gw.api.it.umich.edu/um/bf/Campuses")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['errorCode'].present?
      @result['error'] = response_json['errorCode'] + " - " + response_json['errorMessage']
    else
      @result['success'] = true
      @result['data'] = response_json['Campuses']
    end
    return @result
  end

  # update buildings

  def update_all_buildings(campus_codes = [100], buildings_codes = [])
    @buildings_ids = Building.all.pluck(:bldrecnbr)

    @result = get_buildings_for_current_fiscal_year
    if @result['success']
      data = @result['data']
      data.each do |row|
        if REMOVE_BLDG.include?(row['BuildingRecordNumber'])
          next
        end
        if campus_codes.include?(row['BuildingCampusCode']) || buildings_codes.include?(row['BuildingRecordNumber'])
          if building_exists?(row['BuildingRecordNumber'])
            update_building(row)
          else
            create_building(row)
          end
          return @debug if @debug
        end
      end

      # check if there are buildings in the db that were not updated by API
      if @buildings_ids.present?
        @log.api_logger.info "update_all_buildings: Building(s) not in the API database: #{@buildings_ids}"
      end

    else
      @log.api_logger.debug "update_all_buildings, error: API return: #{@result['error']}"
      @debug = true
      return @debug
    end
    return @debug
  end

  def building_exists?(bldrecnbr)
    @buildings_ids.include?(bldrecnbr)
  end

  def update_building(row)
    building = Building.find_by(bldrecnbr: row['BuildingRecordNumber'])
    if building.update(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
          address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
          city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'usa again', 
          campus_record_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)
      @buildings_ids.delete(row['BuildingRecordNumber'])
    else
      @log.api_logger.debug "update_all_buildings, error: Could not update #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def create_building(row)
    building = Building.new(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
        address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
        city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'USA',
        campus_record_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)

    if building.save
      GeocodeBuildingJob.perform_later(building)
    else
      @log.api_logger.debug "update_all_buildings, error: Could not create #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def get_buildings_for_current_fiscal_year
    url = URI("https://gw.api.it.umich.edu/um/bf/BuildingInfo")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['errorCode'].present?
      @result['error'] = response_json['errorCode'] + " - " + response_json['errorMessage']
    else
      @result['success'] = true
      @result['data'] = response_json['ListOfBldgs']['Buildings']
    end
    return @result

  end

  # update rooms for every building

  def update_rooms
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    dept_auth_token = AuthTokenApi.new("department")
    dept_auth_token_result = dept_auth_token.get_auth_token
    if dept_auth_token_result['success']
      # puts "depts token ok"
      dept_access_token = dept_auth_token_result['access_token']
    else
      puts "Could not get access_token for DepartmentApi. Error: " + dept_auth_token_result['error']
      @log.api_logger.debug "update_rooms, error: Could not get access_token for DepartmentApi: #{dept_auth_token_result['error']}"
      @debug = true
      return @debug
    end
    # dept = DepartmentApi.new(dept_access_token)
    dept_info_array = {}
    number_of_api_calls_per_minutes = 0
    @buildings_ids.each do |bld|
      # puts bld
      @rooms_in_db = Room.where(building_bldrecnbr: bld).where(rmtyp_description: "Classroom").pluck(:rmrecnbr)
      @campus_id = Building.find_by(bldrecnbr: bld).campus_record_id
      @building_name = Building.find_by(bldrecnbr: bld).name
      # puts @building_name
      result = get_building_classroom_data(bld)
      if result['success']
        if result['data'].present?
          data = result['data']          
          if data.present?
            # check data for buildings that have rooms with RoomTypeDescription == "Classroom"
            if data.pluck("RoomTypeDescription").uniq.include?("Classroom")
              data.each do |row|
                # update only Classrooms not all rooms
                if row['RoomTypeDescription'] == "Classroom"
                  # get information about department
                  dept_name = row['DepartmentName']
                  if dept_info_array[dept_name].present?
                    dept_data = dept_info_array[dept_name]
                  else
                    # get data from API
                    if number_of_api_calls_per_minutes < 400
                      number_of_api_calls_per_minutes += 1
                    else
                      number_of_api_calls_per_minutes = 1
                      sleep(61.seconds)
                    end
                    # dept_result = dept.get_departments_info(dept_name)
                    dept_result = DepartmentApi.new(dept_access_token).get_departments_info(dept_name)
                    if dept_result['success']
                      if dept_result['data']['DeptData'].present?
                        dept_data_info = dept_result['data']['DeptData'][0]
                        dept_info_array[dept_name] = 
                                                {'DeptId' => dept_data_info['DeptId'], 
                                                'DeptGroup' => dept_data_info['DeptGroup'], 
                                                'DeptGroupDescription' => dept_data_info['DeptGroupDescription']
                                                }
                        dept_data = dept_info_array[dept_name]
                      else
                        dept_data = nil
                      end
                    else
                      @log.api_logger.debug "update_rooms, error: DepartmentApi: Error for building #{bld}, room #{row['RoomRecordNumber']}, department #{dept_name} - #{dept_result['error']}"
                      dept_data = nil
                      # don't want to interrupt because Department API gives this error: 
                      # Error for building 1005036, room 2108446, department EH&S - 404. Please specify Department Description of more than 3 characters
                      # @debug = true
                      # return @debug
                    end
                  end
                  if room_exists?(bld, row['RoomRecordNumber'])
                    update_room(row, bld, dept_data)
                  else
                    create_room(row, bld, dept_data)
                  end
                  # if update_room or create_room returns true (@debug)
                  return @debug if @debug
                end
              end
            end
          end
        end
        # check if database has rooms that are not in API anymore
        if @rooms_in_db.present?
          if Room.where(rmrecnbr: @rooms_in_db).destroy_all
            @log.api_logger.info "update_rooms, delete #{@rooms_in_db} room(s) from the database"
          else
            @log.api_logger.debug "update_rooms, error: could not delete records with #{@rooms_in_db} rmrecnbr"
            @debug = true
            return @debug
          end
        end
      else
        @log.api_logger.debug "update_rooms, error: API return: #{@result['error']}"
        @debug = true
        return @debug
      end
    end
    return @debug
  end

  def room_exists?(bldrecnbr, rmrecnbr)
    Building.find_by(bldrecnbr: bldrecnbr).rooms.find_by(rmrecnbr: rmrecnbr).present?
  end

  def update_room(row, bld, dept_data)
    room = Room.find_by(rmrecnbr: row['RoomRecordNumber'])
    if dept_data.nil?
      if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
        square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
        dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
        campus_record_id: @campus_id, building_name: @building_name)
        @rooms_in_db.delete(row['RoomRecordNumber'])
      else
        @log.api_logger.debug "update_rooms, error: Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
        @debug = true
        return @debug
      end
    else
      if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
              square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
              dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
              dept_id: dept_data['DeptId'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'],
              campus_record_id: @campus_id, building_name: @building_name)
        @rooms_in_db.delete(row['RoomRecordNumber'])
      else
        @log.api_logger.debug "update_rooms, error: Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
        @debug = true
        return @debug
      end
    end
  end

  def create_room(row, bld, dept_data)
    if dept_data.nil?
      room = Room.new(building_bldrecnbr: bld, rmrecnbr: row['RoomRecordNumber'], floor: row['FloorNumber'], room_number: row['RoomNumber'], 
            square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
            dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
            campus_record_id: @campus_id, building_name: @building_name, visible: true)
    else
      room = Room.new(building_bldrecnbr: bld, rmrecnbr: row['RoomRecordNumber'], floor: row['FloorNumber'], room_number: row['RoomNumber'], 
            square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
            dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
            dept_id: dept_data['DeptId'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'],
            campus_record_id: @campus_id, building_name: @building_name, visible: true)
    end
    unless room.save
      @log.api_logger.debug "update_rooms, error: Could not create #{row['RoomRecordNumber']} because : #{room.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def get_building_classroom_data(bldrecnbr)
    # puts "in get_building_classroom_data"
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @debug = false

    url = URI("https://gw.api.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['errorCode'].present?
      @result['error'] = response_json['errorCode'] + " - " + response_json['errorMessage']
    else
      @result['success'] = true
      building_data = []
      if response_json['ListOfRooms'].nil?
        @result['data'] = nil
      else
        data = response_json['ListOfRooms']['RoomData']
        if data.is_a?(Hash) 
          data = []
          data << response_json['ListOfRooms']['RoomData']
        end
        @result['data'] = data
      end
    end
    return @result

  end
  
end
