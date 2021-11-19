class ClassroomApi

  def initialize(access_token)
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @access_token = access_token
  end

  def classroom_logger
    @@classroom_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_classroom_api.log")
  end

  def facility_id_logger
    @@facility_id_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_facility_id_logger_api.log")
  end

  def contact_logger
    @@contact_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_classroom_contact_api.log")
  end

  def classroom_characteristics_logger
    @@classroom_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_classroom_characteristics_api.log")
  end

  def add_facility_id_to_classrooms(campus_codes = [100], buildinds_codes = [])
    result = get_classrooms_list
    if result['success']
      classrooms_list = result['data'] 
      number_of_api_calls_per_minutes = 0
      classrooms_list.each do |room|
        if number_of_api_calls_per_minutes < 190 
          number_of_api_calls_per_minutes += 1
        else
          number_of_api_calls_per_minutes = 1
          sleep(61.seconds)
        end
        facility_id = room['FacilityID'].to_s
        # add facility_id only if room in the database doesn't have one
        if Room.find_by(facility_code_heprod: facility_id).nil?
          result = get_classroom_info(ERB::Util.url_encode(facility_id))
          if result['success']
            room_info = result['data'][0]
            if campus_codes.include?(room_info['CampusCd'].to_i) || buildinds_codes.include?(room_info['BuildingID'].to_i)
              rmrecnbr = room_info['RmRecNbr'].to_i
              room_in_db = Room.find_by(rmrecnbr: rmrecnbr)
              if room_in_db
                room_in_db.update(facility_code_heprod: facility_id, campus_record_id: CampusRecord.find_by(campus_cd: room_info['CampusCd']).id)
              else
                facility_id_logger.info "Room not in the database: rmrecnbr - #{rmrecnbr}, facility_id - #{facility_id}"
              end
            end
          else
            facility_id_logger.info "did not find room in API room_info for facility_id: #{facility_id}"
          end
        end
      end
    else
      facility_id_logger.debug "API return: #{@result['error']}"
    end
  end

  def update_all_classrooms
    result = get_classrooms_list
    if result['success']
      data = result['data']
      data.each do |row|
        building = row['BuildingID']
        if building_exists?(building)
          result1 = get_classroom_info(row['FacilityID'])
          if classroom_exists?(row['RmRecNbr'])
            update_classroom(row)
          else
            cleate_classroom(row)
          end
        else
          classroom_logger.debug "Building #{row['BuildingID']} doesn't exist in the database"
        end
      end
    end
  end

  def update_classroom(row)
    classroom = Room.find_by(rmrecnbr: row['RmRecNbr'])

    if classroom.update(building_bldrecnbr: row['BuildingID'], instructional_seating_count: row['RmInstSeatCnt'])
      classroom_logger.info "Updated: #{row['RmRecNbr']}"
    else
      classroom_logger.debug "Could not save #{row['RmRecNbr']} because : #{classroom.errors.messages}"
    end
  end

  def building_exists?(bldrecnbr)
    @buildings_ids.include?(bldrecnbr.to_i)
  end

  def classroom_exists?(bldrecnbr, rmrecnbr)
    Building.find_by(bldrecnbr: bldrecnbr).rooms.find_by(rmrecnbr: rmrecnbr).present?
  end

  def get_classrooms_list
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms?BuildingID=1005046")

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
      @result['data'] = response_json['Classrooms']['Classroom']
    end
    return @result
    
  end

  def get_classroom_info(facility_id)
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}")

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
      @result['data'] = response_json['Classrooms']['Classroom']
    end
    return @result
    
  end

  def update_all_classroom_characteristics

    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
    number_of_api_calls_per_minutes = 0
    classrooms.each do |room|
      if number_of_api_calls_per_minutes < 190 
        number_of_api_calls_per_minutes += 1
      else
        number_of_api_calls_per_minutes = 1
        sleep(61.seconds)
      end
      facility_id = room.facility_code_heprod
      rmrecnbr = room.rmrecnbr

      result = get_classroom_characteristics(ERB::Util.url_encode(facility_id))
      if result['success']
        if result['data']['Characteristics'].present?
          characteristics = result['data']['Characteristics']['Characteristic']
          if RoomCharacteristic.where(rmrecnbr: rmrecnbr).present?
            RoomCharacteristic.where(rmrecnbr: rmrecnbr).destroy_all
          end
          create_classroom_characteristics(characteristics)
        else 
          classroom_characteristics_logger.info "no characteristics for facility_id: #{facility_id}"
        end
      else
        classroom_characteristics_logger.debug "API return: #{@result['error']}"
      end
    end
  end

  def create_classroom_characteristics(characteristics)
    characteristics.each do |row|
      room_char = RoomCharacteristic.new(rmrecnbr: row['RmRecNbr'], chrstc_desc254: row['ChrstcDescr254'], 
                  chrstc_descr: row['ChrstcDescr'], chrstc_descrshort: row['ChrstcDescrShort'], chrstc: row['Chrstc'])
      if !room_char.save
        classroom_characteristics_logger.debug "Could not create #{row['RmRecNbr']} because : #{room_char.errors.messages}"
      end
    end

  end

  def get_classroom_characteristics(facility_id)
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}/Characteristics")

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
      @result['data'] = response_json
    end
    return @result

  end

  def update_all_classroom_contacts
    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
    number_of_api_calls_per_minutes = 0
    classrooms.each do |room|
      if number_of_api_calls_per_minutes < 190 
        number_of_api_calls_per_minutes += 1
      else
        number_of_api_calls_per_minutes = 1
        sleep(61.seconds)
      end
      facility_id = room.facility_code_heprod
      rmrecnbr = room.rmrecnbr
      result = get_classroom_contact(ERB::Util.url_encode(facility_id))

      if result['success']
        if result['data']['Classrooms'].present?
          row = result['data']['Classrooms']['Classroom'][0]
          
          if RoomContact.find_by(rmrecnbr: rmrecnbr).present?
            update_classroom_contact(row)
          else
            create_classroom_contact(row)
          end
        else
          contact_logger.debug "No contacts for facility_id #{facility_id}"
        end
      else
        contact_logger.debug "API returns false for facility_id #{facility_id}: #{@result['error']}"
      end
    end

  end

  def update_classroom_contact(row)
    contact = RoomContact.find_by(rmrecnbr: row['RmRecNbr'])
    if !contact.update(rm_schd_cntct_name: row['ContactName'], rm_schd_email: row['Email'], rm_schd_cntct_phone: row['Phone'],
                rm_det_url: row['ScheduleURL'], rm_usage_guidlns_url: row['UsageGuideLinesURL'], rm_sppt_deptid: row['SpptDeptID'],
                rm_sppt_cntct_email: row['SpptCntctEmail'], rm_sppt_cntct_phone: row['SpptCntctPhone'], rm_sppt_cntct_url: row['SpptCntctURL'])
      contact_logger.debug "Could not update #{row['RmRecNbr']} because : #{contact.errors.messages}"
    end
  end

  def create_classroom_contact(row)
    contact = RoomContact.new(rmrecnbr: row['RmRecNbr'], rm_schd_cntct_name: row['ContactName'], rm_schd_email: row['Email'], rm_schd_cntct_phone: row['Phone'],
    rm_det_url: row['ScheduleURL'], rm_usage_guidlns_url: row['UsageGuideLinesURL'], rm_sppt_deptid: row['SpptDeptID'],
    rm_sppt_cntct_email: row['SpptCntctEmail'], rm_sppt_cntct_phone: row['SpptCntctPhone'], rm_sppt_cntct_url: row['SpptCntctURL'])
    if !contact.save
      contact_logger.debug "Could not create #{row['RmRecNbr']} because : #{contact.errors.messages}"
    end
  end

  def get_classroom_contact(facility_id)
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}/Contacts")
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
      @result['data'] = response_json
    end
    return @result

  end

  def get_classroom_meetings(start_date, end_date)
    puts ("in meetings")
    url = URI("https://apigw.it.umich.edu/um/aa/ClassroomList/Classrooms/#{@rmrecnbr}/Meetings?startDate=#{start_date}&endDate=#{end_date}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    return JSON.parse(response.read_body)
 
  end

end
