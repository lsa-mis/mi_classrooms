class ClassroomApi

  def initialize(access_token)
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @access_token = access_token
    @debug = false
    @log = ApiLog.new
  end

  def add_facility_id_to_classrooms(campus_codes = [100], buildings_codes = [])
    @rooms_in_db = Room.all.pluck(:rmrecnbr)
    result = get_classrooms_list
    if result['success']
      classrooms_list = result['data'] 
      number_of_api_calls_per_minutes = 0
      classrooms_list.each do |room|
        # update only rooms for campuses and buildings from the MClassroom database
        if @buildings_ids.include?(room['BuildingID'].to_i)
          if number_of_api_calls_per_minutes < 400
            number_of_api_calls_per_minutes += 1
          else
            @log.api_logger.debug "add_facility_id_to_classrooms, the script sleeps after #{number_of_api_calls_per_minutes} calls"
            number_of_api_calls_per_minutes = 1
            sleep(61.seconds)
          end
          facility_id = room['FacilityID'].to_s
          # add facility_id and number of seats
          result = get_classroom_info(ERB::Util.url_encode(facility_id))
          if result['error'] == "Resource access limit reached"
            @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{@result['error']} after #{number_of_api_calls_per_minutes} calls"
            number_of_api_calls_per_minutes = 1
            sleep(61.seconds)
            result = get_classroom_info(ERB::Util.url_encode(facility_id))
          end
          if result['success']
            room_info = result['data'][0]
            rmrecnbr = room_info['RmRecNbr'].to_i
            room_in_db = Room.find_by(rmrecnbr: rmrecnbr)
            if room_in_db
              if room_in_db.update(facility_code_heprod: facility_id, instructional_seating_count: room_info['RmInstSeatCnt'], campus_record_id: CampusRecord.find_by(campus_cd: room_info['CampusCd']).id)
                @rooms_in_db.delete(rmrecnbr)
              else
                @log.api_logger.debug "add_facility_id_to_classrooms, error: Could not update: rmrecnbr - #{rmrecnbr}, facility_id - #{facility_id}"
                @debug = true
                return @debug
              end
            end
          else
            @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{@result['error']} for #{facility_id}"
          end
        end
      end
    else
      @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{@result['error']} for #{facility_id}"
      @debug = true
      return @debug
    end
    # check if database has rooms that are not in API anymore
    if @rooms_in_db.present?
      if Room.where(rmrecnbr: @rooms_in_db).delete_all
        @log.api_logger.info "add_facility_id_to_classrooms, delete #{@rooms_in_db} room(s) from the database"
      else
        @log.api_logger.debug "add_facility_id_to_classrooms, error: could not delete records with #{@rooms_in_db} rmrecnbr"
        @debug = true
        return @debug
      end
    end
    return @debug
  end


  def get_classrooms_list
    url = URI("https://gw.api.it.umich.edu/um/aa/ClassroomList/Classrooms?BuildingID=1005046")

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
      @result['data'] = response_json['Classrooms']['Classroom']
    end
    return @result
    
  end

  def get_classroom_info(facility_id)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @debug = false
    # puts "in get_classroom_info"
    # puts facility_id
    url = URI("https://gw.api.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["x-ibm-client-id"] = "#{Rails.application.credentials.um_api[:buildings_client_id]}"
    request["authorization"] = "Bearer #{@access_token}"
    request["accept"] = 'application/json'

    response = http.request(request)
    response_json = JSON.parse(response.read_body)
    if response_json.present?
      if response_json['errorCode'].present?
        @result['error'] = response_json['errorCode'] + " - " + response_json['errorMessage']
        @result['success'] = false
      else
        @result['success'] = true
        @result['data'] = response_json['Classrooms']['Classroom']
      end
    end
    return @result
  end

  def update_all_classroom_characteristics

    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
    number_of_api_calls_per_minutes = 0
    classrooms.each do |room|
      if number_of_api_calls_per_minutes < 400
        number_of_api_calls_per_minutes += 1
      else
        @log.api_logger.debug "update_all_classroom_characteristics, the script sleeps after #{number_of_api_calls_per_minutes} calls"
        number_of_api_calls_per_minutes = 1
        sleep(61.seconds)
      end
      facility_id = room.facility_code_heprod
      rmrecnbr = room.rmrecnbr

      result = get_classroom_characteristics(ERB::Util.url_encode(facility_id))
      if result['error'] == "Resource access limit reached"
        @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{@result['error']} after #{number_of_api_calls_per_minutes} calls"
        number_of_api_calls_per_minutes = 1
        sleep(61.seconds)
        result = get_classroom_characteristics(ERB::Util.url_encode(facility_id))
      end
      if result['success']
        if result['data']['Characteristics'].present?
          characteristics = result['data']['Characteristics']['Characteristic']
          if RoomCharacteristic.where(rmrecnbr: rmrecnbr).present?
            db_chrstc_list = RoomCharacteristic.where(rmrecnbr: rmrecnbr).pluck(:chrstc)
            characteristics.each do |c|
              # add characteristics if they are not in database
              if db_chrstc_list.include?(c['Chrstc'].to_i)
                db_chrstc_list.delete(c['Chrstc'].to_i)
              else
                add_classroom_characteristic(c)
              end
              return @debug if @debug
            end
            # delete characteristics that are not in API
            db_chrstc_list.each do |c|
              RoomCharacteristic.where(rmrecnbr: rmrecnbr).where(chrstc: c).destroy_all
            end
          else
            create_classroom_characteristics(characteristics)
          end
        else
          @log.api_logger.info "update_all_classroom_characteristics, no characteristics for facility_id: #{facility_id}"
        end
      else
        @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{@result['error']}"
        @debug = true
        return @debug
      end
      return @debug if @debug
    end
    return @debug
  end

  def add_classroom_characteristic(row)
    chrstc_descrshort = row['ChrstcDescrShort'].gsub(/[^0-9A-Za-z]/, '')
    room_char = RoomCharacteristic.new(rmrecnbr: row['RmRecNbr'], chrstc_desc254: row['ChrstcDescr254'], 
                chrstc_descr: row['ChrstcDescr'], chrstc_descrshort: chrstc_descrshort, chrstc: row['Chrstc'])
    unless room_char.save
      @log.api_logger.debug "update_all_classroom_characteristics, error: Could not add #{row['RmRecNbr']} because : #{room_char.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def create_classroom_characteristics(characteristics)
    characteristics.each do |row|
      chrstc_descrshort = row['ChrstcDescrShort'].gsub(/[^0-9A-Za-z]/, '')
      room_char = RoomCharacteristic.new(rmrecnbr: row['RmRecNbr'], chrstc_desc254: row['ChrstcDescr254'], 
                  chrstc_descr: row['ChrstcDescr'], chrstc_descrshort: chrstc_descrshort, chrstc: row['Chrstc'])
      unless room_char.save
        @log.api_logger.debug "update_all_classroom_characteristics, error: Could not create #{row['RmRecNbr']} because : #{room_char.errors.messages}"
        @debug = true
        return @debug
      end
    end

  end

  def get_classroom_characteristics(facility_id)
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @debug = false
    url = URI("https://gw.api.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}/Characteristics")

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
      @result['data'] = response_json
    end
    return @result

  end

  def update_all_classroom_contacts
    @result = {'success' => false, 'error' => '', 'data' => {}}
    @debug = false
    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
    number_of_api_calls_per_minutes = 0
    classrooms.each do |room|
      if number_of_api_calls_per_minutes < 400
        number_of_api_calls_per_minutes += 1
      else
        @log.api_logger.debug "update_all_classroom_contacts, the script sleeps after #{number_of_api_calls_per_minutes} calls"
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
            update_classroom_contact(row, rmrecnbr)
          else
            create_classroom_contact(row, rmrecnbr)
          end
        else
          @log.api_logger.info "update_all_classroom_contacts, No contacts for facility_id #{facility_id}"
        end
      else
        @log.api_logger.debug "update_all_classroom_contacts, error: API returns false for facility_id #{facility_id}: #{@result['error']}"
        @debug = true
        return @debug
      end
      return @debug if @debug
    end
    return @debug
  end

  def update_classroom_contact(row, rmrecnbr)
    contact = RoomContact.find_by(rmrecnbr: rmrecnbr)
    unless contact.update(rm_schd_cntct_name: row['ContactName'], rm_schd_email: row['Email'], rm_schd_cntct_phone: row['Phone'],
                rm_det_url: row['ScheduleURL'], rm_usage_guidlns_url: row['UsageGuideLinesURL'], rm_sppt_deptid: row['SpptDeptID'],
                rm_sppt_cntct_email: row['SpptCntctEmail'], rm_sppt_cntct_phone: row['SpptCntctPhone'], rm_sppt_cntct_url: row['SpptCntctURL'])
      
      @log.api_logger.debug "update_all_classroom_contacts, error: Could not update #{rmrecnbr} because : #{contact.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def create_classroom_contact(row, rmrecnbr)
    contact = RoomContact.new(rmrecnbr: rmrecnbr, rm_schd_cntct_name: row['ContactName'], rm_schd_email: row['Email'], rm_schd_cntct_phone: row['Phone'],
    rm_det_url: row['ScheduleURL'], rm_usage_guidlns_url: row['UsageGuideLinesURL'], rm_sppt_deptid: row['SpptDeptID'],
    rm_sppt_cntct_email: row['SpptCntctEmail'], rm_sppt_cntct_phone: row['SpptCntctPhone'], rm_sppt_cntct_url: row['SpptCntctURL'])
    unless contact.save
      @log.api_logger.debug "update_all_classroom_contacts, error: Could not create #{rmrecnbr} because : #{contact.errors.messages}"
      @debug = true
      return @debug
    end
  end

  def get_classroom_contact(facility_id)
    url = URI("https://gw.api.it.umich.edu/um/aa/ClassroomList/Classrooms/#{facility_id}/Contacts")
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
      @result['data'] = response_json
    end
    return @result

  end

  def get_classroom_meetings(start_date, end_date)
    url = URI("https://gw.api.it.umich.edu/um/aa/ClassroomList/Classrooms/#{@rmrecnbr}/Meetings?startDate=#{start_date}&endDate=#{end_date}")
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
