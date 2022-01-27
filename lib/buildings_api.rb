class BuildingsApi

  def initialize(access_token)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @access_token = access_token
  end

  def building_logger
    @@building_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_building_api.log")
  end

  def room_logger
    @@room_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_room_api.log")
  end

  def campus_logger
    @@campus_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_campus_api.log")
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
      end
      # check if database has information that is not in API anymore
      if @campus_cds.present?
        campus_logger.info "Campus record(s) not in the API database: #{@campus_cds}"
      end
    else
      campus_logger.debug "API return: #{@result['error']}"
      @debug = true
    end
  end

  def campus_exists?(campus_cd)
    @campus_cds.include?(campus_cd)
  end

  def update_campus(row)
    campus = CampusRecord.find_by(campus_cd: row['CampusCd'])

    if campus.update(campus_description: row['CampusDescr'])
      @campus_cds.delete(row['CampusCd'])
    else
      campus_logger.debug "Could not update #{row['CampusCd']} because : #{campus.errors.messages}"
      @debug = true
    end
  end

  def create_campus(row)
    campus = CampusRecord.new(campus_cd: row['CampusCd'], campus_description: row['CampusDescr'])

    unless campus.save
      campus_logger.info "Could not create #{row['CampusCd']} because : #{campus.errors.messages}"
    end
  end

  def get_campuses 
    url = URI("https://apigw.it.umich.edu/um/bf/Campuses")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true
      @result['data'] = response_json['Campuses']
    end
    return @result
  end

  # update builgings

  def update_all_buildings(campus_codes = [100], buildings_codes = [])
    @buildings_ids = Building.all.pluck(:bldrecnbr)

    @result = get_buildings_for_current_fiscal_year
    if @result['success']
      data = @result['data']
      data.each do |row|
        if campus_codes.include?(row['BuildingCampusCode']) || buildings_codes.include?(row['BuildingRecordNumber'])
          if building_exists?(row['BuildingRecordNumber'])
            update_building(row)
          else
            create_building(row)
          end
        end
      end
      # check if there buildings that were not updated
      if @buildings_ids.present?
        building_logger.info "Building(s) not in the API database: #{@buildings_ids}"
      end
    else
      building_logger.debug "API return: #{@result['error']}"
    end
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
      building_logger.debug "Could not update #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
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
      building_logger.debug "Could not create #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
    end
  end

  def get_buildings_for_current_fiscal_year
    url = URI("https://apigw.it.umich.edu/um/bf/BuildingInfo")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
    else
      @result['success'] = true
      @result['data'] = response_json['ListOfBldgs']['Buildings']
    end
    return @result

  end

  # update rooms for every building

  def update_rooms
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    @rooms_not_updated = []
    dept_auth_token = AuthTokenApi.new("bf", "department")
    dept_auth_token_result = dept_auth_token.get_auth_token
    if dept_auth_token_result['success']
      dept_access_token = dept_auth_token_result['access_token']
    else
      puts "Could not get access_token for DepartmentApi. Error: " + result['error']
      exit
    end
    dept = DepartmentApi.new(dept_access_token)
    dept_info_array = {}
    number_of_api_calls_per_minutes = 0
    @buildings_ids.each do |bld|
      @campus_id = Building.find_by(bldrecnbr: bld).campus_record_id
      @building_name = Building.find_by(bldrecnbr: bld).name
      result = get_building_classroom_data(bld)
      if result['success']
        if result['data'].present?
          data = result['data']
          @rooms_in_db = Room.where(building_bldrecnbr: bld).pluck(:rmrecnbr)
          if data.present?
            data.each do |row|
              # get information about department
              dept_name = row['DepartmentName']
              if dept_info_array[dept_name].present?
                dept_data = dept_info_array[dept_name]
              else
                # get data from API
                if number_of_api_calls_per_minutes < 190 
                  number_of_api_calls_per_minutes += 1
                else
                  number_of_api_calls_per_minutes = 1
                  sleep(61.seconds)
                end
                dept_result = dept.get_departments_info(dept_name)
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
                  room_logger.info "DepartmentApi: Error for building #{bld}, room #{row['RoomRecordNumber']}, department #{dept_name} - #{dept_result['error']}"
                  dept_data = nil
                end
              end
              if room_exists?(bld, row['RoomRecordNumber'])
                update_room(row, bld, dept_data)
              else
                create_room(row, bld, dept_data)
              end
            end
          end
        else
          room_logger.info "No classrooms for building: #{bld}"
        end
        # check if database has rooms that are not in API anymore
        if @rooms_not_updated.present?
          @rooms_not_updated.each do |rmrecnbr|
            room = Room.find_by(rmrecnbr: rmrecnbr)
            unless room.update(visible: false)
              room_logger.info "Could not update room #{rmrecnbr} - should have visible = false "
            end
          end
        end
      else
        room_logger.info "API return: #{@result['error']}"
      end
      @rooms_not_updated += @rooms_in_db if @rooms_in_db
    end
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
        campus_record_id: @campus_id, building_name: @building_name, visible: true)
        @rooms_in_db.delete(row['RoomRecordNumber'])
      else
        room_logger.info "Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
      end
    else
      if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
              square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
              dept_description: row['DepartmentName'], instructional_seating_count: row['RoomStationCount'],
              dept_id: dept_data['DeptId'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'],
              campus_record_id: @campus_id, building_name: @building_name, visible: true)
        @rooms_in_db.delete(row['RoomRecordNumber'])
      else
        room_logger.info "Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
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
      room_logger.info "Could not create #{row['RoomRecordNumber']} because : #{room.errors.messages}"
    end
  end

  def get_building_classroom_data(bldrecnbr)
    url = URI("https://apigw.it.umich.edu/um/bf/RoomInfo/#{bldrecnbr}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json['httpCode'].present?
      @result['error'] = response_json['httpMessage'] + ". " + response_json['moreInformation']
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
