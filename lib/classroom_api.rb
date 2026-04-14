class ClassroomApi
  BASE_URL = "https://gw.api.it.umich.edu/um/aa/ClassroomList/v2".freeze

  ERROR_CODE_ERR429 = "ERR429"
  NUMBER_OF_API_CALLS = 400

  def initialize(access_token = nil)
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    @client = UmApi::Connection.new(access_token: access_token, scope: "classrooms")
    @debug = false
    @log = ApiLog.new
  end

  def add_facility_id_to_classrooms
    begin
      @rooms_in_db = Room.all.pluck(:rmrecnbr)
      result = get_classrooms_list
      if result['success']
        classrooms_list = result['data']
        number_of_api_calls_per_minutes = 0
        redo_loop_number = 1
        classrooms_list.each do |room|
          # update only rooms for campuses and buildings from the MClassroom database
          if @buildings_ids.include?(room['BuildingID'].to_i)
            if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
              number_of_api_calls_per_minutes += 1
            else
              @log.api_logger.debug "add_facility_id_to_classrooms, the script sleeps after #{number_of_api_calls_per_minutes} calls"
              number_of_api_calls_per_minutes = 1
              sleep(61.seconds)
            end
            facility_id = room['FacilityID'].to_s
            # add facility_id and number of seats
            result = get_classroom_info(ERB::Util.url_encode(facility_id))
            if result['errorcode'] == ERROR_CODE_ERR429
              @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls"
              number_of_api_calls_per_minutes = 0
              sleep(61.seconds)
              if redo_loop_number > 9
                @debug = true
                @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times "
                sleep(61.seconds)
                return @debug
              end
              redo_loop_number += 1
              redo
            elsif result['success'] 
              if result['data']['Classroom'].present?
                room_info = result['data']['Classroom'][0]
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
              end
            else
              @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{result['errorcode']} - #{result['error']} for #{facility_id}"
              @debug = true
              sleep(61.seconds)
              return @debug
            end
          end
        end
      else
        @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{result['errorcode']} - #{result['error']}"
        @debug = true
        sleep(61.seconds)
        return @debug
      end
      # check if database has rooms that are not in API anymore
      if @rooms_in_db.present?
        RoomContact.where(rmrecnbr: @rooms_in_db).delete_all
        RoomCharacteristic.where(rmrecnbr: @rooms_in_db).delete_all
        if Room.where(rmrecnbr: @rooms_in_db).delete_all
          @log.api_logger.info "add_facility_id_to_classrooms, delete #{@rooms_in_db} room(s) from the database"
        else
          @log.api_logger.debug "add_facility_id_to_classrooms, error: could not delete records with #{@rooms_in_db} rmrecnbr"
          @debug = true
          return @debug
        end
      end
    rescue StandardError => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      @log.api_logger.debug "add_facility_id_to_classrooms, error: API return: #{e.message}"
      @debug = true
      sleep(61.seconds)
    end
    return @debug
  end


  def get_classrooms_list
    strip_headers(
      @client.paginated_get(
        "#{BASE_URL}/Classrooms",
        collection_path: %w[Classrooms Classroom]
      )
    )
  end

  def get_classroom_info(facility_id)
    @debug = false
    response = @client.get_json("#{BASE_URL}/Classrooms/#{facility_id}")
    return strip_headers(response) unless response["success"]

    success_result(response["data"]["Classrooms"])
  end

  def update_all_classroom_characteristics
    begin
      classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
      number_of_api_calls_per_minutes = 0
      redo_loop_number = 1
      classrooms.each do |room|
        if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
          number_of_api_calls_per_minutes += 1
        else
          @log.api_logger.debug "update_all_classroom_characteristics, the script sleeps after #{number_of_api_calls_per_minutes} calls"
          number_of_api_calls_per_minutes = 1
          sleep(61.seconds)
        end
        facility_id = room.facility_code_heprod
        rmrecnbr = room.rmrecnbr
        result = get_classroom_characteristics(ERB::Util.url_encode(facility_id))
        if result['errorcode'] == ERROR_CODE_ERR429
          @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls"
          number_of_api_calls_per_minutes = 0
          sleep(61.seconds)
          if redo_loop_number > 9
            @debug = true
            @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times "
            sleep(61.seconds)
            return @debug
          end
          redo_loop_number += 1
          redo
        elsif result['success']
          characteristics = result['data']['Classroom']
          if characteristics.present?
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
                RoomCharacteristic.where(rmrecnbr: rmrecnbr).where(chrstc: c).delete_all
              end
            else
              create_classroom_characteristics(characteristics)
            end
          else
            @log.api_logger.info "update_all_classroom_characteristics, no characteristics for facility_id: #{facility_id}"
          end
        else
          @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{result['errorcode']} - #{result['error']}"
          @debug = true
          sleep(61.seconds)
          return @debug
        end
        return @debug if @debug
      end
    rescue StandardError => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      @log.api_logger.debug "update_all_classroom_characteristics, error: API return: #{e.message}"
      @debug = true
      sleep(61.seconds)
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
    @debug = false
    response = @client.get_json("#{BASE_URL}/Classrooms/#{facility_id}/Characteristics")
    return strip_headers(response) unless response["success"]

    success_result(response["data"]["Classrooms"])
  end

  def update_all_classroom_contacts
    begin
      result = {'success' => false, 'errorcode' => '', 'error' => '', 'data' => {}}
      @debug = false
      classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
      number_of_api_calls_per_minutes = 0
      redo_loop_number = 1
      classrooms.each do |room|
        if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
          number_of_api_calls_per_minutes += 1
        else
          @log.api_logger.debug "update_all_classroom_contacts, the script sleeps after #{number_of_api_calls_per_minutes} calls"
          number_of_api_calls_per_minutes = 1
          sleep(61.seconds)
        end
        facility_id = room.facility_code_heprod
        rmrecnbr = room.rmrecnbr
        result = get_classroom_contact(ERB::Util.url_encode(facility_id))
        if result['errorcode'] == ERROR_CODE_ERR429
          @log.api_logger.debug "update_all_classroom_contacts, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls"
          number_of_api_calls_per_minutes = 0
          sleep(61.seconds)
          if redo_loop_number > 9
            @debug = true
            @log.api_logger.debug "update_all_classroom_contacts, error: API return: #{result['errorcode']} - #{result['error']} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times "
            sleep(61.seconds)
            return @debug
          end
          redo_loop_number += 1
          redo
        elsif result['success']
          if result['data']['Classroom'].present?
            row = result['data']['Classroom'][0]
            if RoomContact.find_by(rmrecnbr: rmrecnbr).present?
              update_classroom_contact(row, rmrecnbr)
            else
              create_classroom_contact(row, rmrecnbr)
            end
          else
            @log.api_logger.info "update_all_classroom_contacts, No contacts for facility_id #{facility_id}"
          end
        else
          @log.api_logger.debug "update_all_classroom_contacts, error: API returns false for facility_id #{facility_id}: #{result['errorcode']} - #{result['error']}"
          @debug = true
          sleep(61.seconds)
          return @debug
        end
        return @debug if @debug
      end
    rescue StandardError => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      @log.api_logger.debug "update_all_classroom_contacts, error: API return: #{e.message}"
      @debug = true
      sleep(61.seconds)
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
    response = @client.get_json("#{BASE_URL}/Classrooms/#{facility_id}/Contacts")
    return strip_headers(response) unless response["success"]

    success_result(response["data"]["Classrooms"])
  end

  def get_classroom_meetings(start_date, end_date)
    response = @client.get_json(
      "#{BASE_URL}/Classrooms/#{@rmrecnbr}/Meetings",
      query: { startDate: start_date, endDate: end_date }
    )
    response["data"]
  end

  private

  def success_result(data)
    { "success" => true, "errorcode" => "", "error" => "", "data" => data }
  end

  def strip_headers(result)
    result.except("headers")
  end

end
