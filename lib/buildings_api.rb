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
      campus_logger.info "API return: #{@result['error']}"
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
      campus_logger.info "Could not update #{row['CampusCd']} because : #{campus.errors.messages}"
    end
  end

  def create_campus(row)
    campus = CampusRecord.new(campus_cd: row['CampusCd'], campus_description: row['CampusDescr'])

    if !campus.save
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

  def update_all_buildings(campus_codes = [100])
    @buildings_ids = Building.all.pluck(:bldrecnbr)

    @result = get_buildings_for_current_fiscal_year
    if @result['success']
      data = @result['data']
      data.each do |row|
        if campus_codes.include?(row['BuildingCampusCode'])
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
      building_logger.info "API return: #{@result['error']}"
    end
  end

  def building_exists?(bldrecnbr)
    @buildings_ids.include?(bldrecnbr)
  end

  def update_building(row)
    building = Building.find_by(bldrecnbr: row['BuildingRecordNumber'])
    if building.update(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], nick_name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
          address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
          city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'usa again', 
          campus_records_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)
      @buildings_ids.delete(row['BuildingRecordNumber'])
    else
      building_logger.info "Could not update #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
    end
  end

  def create_building(row)
    building = Building.new(bldrecnbr: row['BuildingRecordNumber'], name: row['BuildingLongDescription'], nick_name: row['BuildingLongDescription'], abbreviation: row['BuildingShortDescription'], 
        address: " #{row['BuildingStreetNumber']}  #{row['BuildingStreetDirection']}  #{row['BuildingStreetName']}".strip.gsub(/\s+/, " "), 
        city: row['BuildingCity'], state: row['BuildingState'], zip: row['BuildingPostal'], country: 'USA',
        campus_records_id: CampusRecord.find_by(campus_cd: row['BuildingCampusCode']).id)

    if building.save
      GeocodeBuildingJob.perform_later(building)
    else
      building_logger.info "Could not create #{row['BuildingRecordNumber']} because : #{building.errors.messages}"
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
      @campus_records_id = Building.find_by(bldrecnbr: bld).campus_records_id
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
                department_record = Department.find_by(dept_description: dept_name)
                puts "department_record"
                puts dept_data
                puts department_record.id
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
                                            {'DepartmentName' => dept_name,
                                            'DeptId' => dept_data_info['DeptId'], 
                                            'DeptGroup' => dept_data_info['DeptGroup'], 
                                            'DeptGroupDescription' => dept_data_info['DeptGroupDescription']
                                            }
                    dept_data = dept_info_array[dept_name]
                    department_record = update_department(dept_data)
                    puts "department_record from API"
                    puts department_record.id
                  else
                    department_record = nil
                  end
                else
                  room_logger.info "DepartmentApi: Error for building #{bld}, room #{row['RoomRecordNumber']}, department #{dept_name} - #{dept_result['error']}"
                  department_record = nil
                end
              end
              if room_exists?(bld, row['RoomRecordNumber'])
                puts "call update room"
                update_room(row, bld, department_record)
              else
                create_room(row, bld, department_record)
              end
              # exit
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
      @rooms_not_updated += @rooms_in_db
    end
  end

  def room_exists?(bldrecnbr, rmrecnbr)
    Building.find_by(bldrecnbr: bldrecnbr).rooms.find_by(rmrecnbr: rmrecnbr).present?
  end

  def update_room(row, bld, department_record)
    if department_record.nil?
      room_logger.info "department record nis nil for room : #{row['RoomRecordNumber']}"
    else
      puts "in update room"
      room = Room.find_by(rmrecnbr: row['RoomRecordNumber'])
      puts room.rmrecnbr
      puts department_record.id
      if room.update(floor: row['FloorNumber'], room_number: row['RoomNumber'], 
              square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
              instructional_seating_count: row['RoomStationCount'],
              campus_records_id: @campus_records_id, departments_id: department_record.id)
        @rooms_in_db.delete(row['RoomRecordNumber'])
        puts "updated"
      else
        puts room.errors.full_messages
        room_logger.info "Could not update #{row['RoomRecordNumber']} because : #{room.errors.messages}"
      end
    end
  end

  def create_room(row, bld, department_record)
    room = Room.new(building_bldrecnbr: bld, rmrecnbr: row['RoomRecordNumber'], floor: row['FloorNumber'], room_number: row['RoomNumber'], 
            square_feet: row['RoomSquareFeet'], rmtyp_description: row['RoomTypeDescription'],
            instructional_seating_count: row['RoomStationCount'],
            campus_records_id: @campus_records_id, departments_id: department_record.id, visible: true)
    unless room.save
      room_logger.info "Could not create #{row['RoomRecordNumber']} because : #{room.errors.messages}"
    end
  end

  def update_department(dept_data)
    
    if Department.find_by(dept_id: dept_data['DeptId'])
      department = Department.find_by(dept_id: dept_data['DeptId'])
      puts "in update department"
      puts department.id
      unless department.update(dept_id: dept_data['DeptId'], dept_description: dept_data['DepartmentName'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'])
        room_logger.info "Could not update department #{dept_data['DepartmentName']} because : #{department.errors.messages}"
      end
    else
      department = Department.new(dept_id: dept_data['DeptId'], dept_description: dept_data['DepartmentName'], dept_grp: dept_data['DeptGroup'], dept_group_description: dept_data['DeptGroupDescription'])
      unless department.save
        room_logger.info "Could not create department #{dept_data['DepartmentName']} because : #{department.errors.messages}"
      end
    end
    return department
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
