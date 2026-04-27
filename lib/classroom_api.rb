class ClassroomApi
  BASE_URL = "https://gw.api.it.umich.edu/um/aa/ClassroomList/v2".freeze

  ERROR_CODE_ERR429 = "ERR429"
  NUMBER_OF_API_CALLS = 400

  attr_reader :last_result, :affected_characteristic_room_ids

  def initialize(access_token = nil, delete_dry_run: false)
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    @client = UmApi::Connection.new(access_token: access_token, scope: "classrooms")
    @debug = false
    @log = ApiLog.new
    @delete_dry_run = delete_dry_run
    @last_result = nil
    @affected_characteristic_room_ids = []
  end

  def add_facility_id_to_classrooms
    start_result("Add FacilityID to Classrooms")
    begin
      @rooms_in_db = Room.where(rmtyp_description: "Classroom").pluck(:rmrecnbr)
      result = get_classrooms_list
      increment(:api_calls)
      if result["success"]
        classrooms_list = result["data"]
        number_of_api_calls_per_minutes = 0
        redo_loop_number = 1
        classrooms_list.each do |room|
          # update only rooms for campuses and buildings from the MClassroom database
          if @buildings_ids.include?(room["BuildingID"].to_i)
            if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
              number_of_api_calls_per_minutes += 1
            else
              add_warning("add_facility_id_to_classrooms, the script sleeps after #{number_of_api_calls_per_minutes} calls")
              number_of_api_calls_per_minutes = 1
              sleep(61.seconds)
              increment(:rate_limit_sleeps)
            end
            facility_id = room["FacilityID"].to_s
            # add facility_id and number of seats
            result = get_classroom_info(ERB::Util.url_encode(facility_id))
            increment(:api_calls)
            if result["errorcode"] == ERROR_CODE_ERR429
              add_warning("add_facility_id_to_classrooms, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls")
              number_of_api_calls_per_minutes = 0
              sleep(61.seconds)
              increment(:rate_limit_sleeps)
              if redo_loop_number > 9
                add_error("add_facility_id_to_classrooms, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times ")
                sleep(61.seconds)
                increment(:rate_limit_sleeps)
                return finish_result
              end
              redo_loop_number += 1
              increment(:retries)
              redo
            elsif result["success"]
              if result["data"]["Classroom"].present?
                room_info = result["data"]["Classroom"][0]
                rmrecnbr = room_info["RmRecNbr"].to_i
                room_in_db = Room.find_by(rmrecnbr: rmrecnbr)
                if room_in_db
                  if room_in_db.update(
                    facility_code_heprod: facility_id,
                    instructional_seating_count: room_info["RmInstSeatCnt"],
                    campus_record_id: CampusRecord.find_by(campus_cd: room_info["CampusCd"]).id,
                    visible: true
                  )
                    increment(:updated)
                    @rooms_in_db.delete(rmrecnbr)
                  else
                    add_error("add_facility_id_to_classrooms, error: Could not update: rmrecnbr - #{rmrecnbr}, facility_id - #{facility_id}")
                    return finish_result
                  end
                else
                  increment(:skipped)
                end
              end
            else
              add_error("add_facility_id_to_classrooms, error: API return: #{result["errorcode"]} - #{result["error"]} for #{facility_id}")
              sleep(61.seconds)
              increment(:rate_limit_sleeps)
              return finish_result
            end
          else
            increment(:skipped)
          end
        end
      else
        add_error("add_facility_id_to_classrooms, error: API return: #{result["errorcode"]} - #{result["error"]}")
        sleep(61.seconds)
        increment(:rate_limit_sleeps)
        return finish_result
      end
      # check if database has rooms that are not in API anymore
      if @rooms_in_db.present?
        if @delete_dry_run
          increment(:would_delete, @rooms_in_db.count)
          add_warning("add_facility_id_to_classrooms, dry run: would deactivate #{@rooms_in_db} stale room(s)")
        else
          deactivated_count = deactivate_stale_rooms("add_facility_id_to_classrooms")
          if deactivated_count
            increment(:deactivated, deactivated_count)
            @log.api_logger.info "add_facility_id_to_classrooms, deactivated #{@rooms_in_db} stale room(s)"
          else
            add_error("add_facility_id_to_classrooms, error: could not deactivate records with #{@rooms_in_db} rmrecnbr")
            return finish_result
          end
        end
      end
    rescue => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      add_error("add_facility_id_to_classrooms, error: API return: #{e.message}")
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
    end
    finish_result
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
    start_result("Update classroom characteristics")
    @affected_characteristic_room_ids = []
    begin
      classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
      number_of_api_calls_per_minutes = 0
      redo_loop_number = 1
      classrooms.each do |room|
        if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
          number_of_api_calls_per_minutes += 1
        else
          add_warning("update_all_classroom_characteristics, the script sleeps after #{number_of_api_calls_per_minutes} calls")
          number_of_api_calls_per_minutes = 1
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
        end
        facility_id = room.facility_code_heprod
        rmrecnbr = room.rmrecnbr
        result = get_classroom_characteristics(ERB::Util.url_encode(facility_id))
        increment(:api_calls)
        @affected_characteristic_room_ids << rmrecnbr
        if result["errorcode"] == ERROR_CODE_ERR429
          add_warning("update_all_classroom_characteristics, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls")
          number_of_api_calls_per_minutes = 0
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
          if redo_loop_number > 9
            add_error("update_all_classroom_characteristics, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times ")
            sleep(61.seconds)
            increment(:rate_limit_sleeps)
            return finish_result
          end
          redo_loop_number += 1
          increment(:retries)
          redo
        elsif result["success"]
          characteristics = result["data"]["Classroom"]
          if characteristics.present?
            if RoomCharacteristic.where(rmrecnbr: rmrecnbr).present?
              db_chrstc_list = RoomCharacteristic.where(rmrecnbr: rmrecnbr).pluck(:chrstc)
              characteristics.each do |c|
                # add characteristics if they are not in database
                if db_chrstc_list.include?(c["Chrstc"].to_i)
                  db_chrstc_list.delete(c["Chrstc"].to_i)
                  increment(:updated)
                else
                  add_classroom_characteristic(c)
                end
                return finish_result if @debug
              end
              # delete characteristics that are not in API
              db_chrstc_list.each do |c|
                increment(:deleted, RoomCharacteristic.where(rmrecnbr: rmrecnbr).where(chrstc: c).delete_all)
              end
            else
              create_classroom_characteristics(characteristics)
            end
          else
            add_warning("update_all_classroom_characteristics, no characteristics for facility_id: #{facility_id}")
            deleted_count = RoomCharacteristic.where(rmrecnbr: rmrecnbr).delete_all
            increment(:deleted, deleted_count)
          end
        else
          add_error("update_all_classroom_characteristics, error: API return: #{result["errorcode"]} - #{result["error"]}")
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
          return finish_result
        end
        return finish_result if @debug
      end
    rescue => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      add_error("update_all_classroom_characteristics, error: API return: #{e.message}")
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
    end
    add_metadata(:affected_room_ids, @affected_characteristic_room_ids.uniq)
    finish_result
  end

  def add_classroom_characteristic(row)
    chrstc_descrshort = row["ChrstcDescrShort"].gsub(/[^0-9A-Za-z]/, "")
    room_char = RoomCharacteristic.new(rmrecnbr: row["RmRecNbr"], chrstc_desc254: row["ChrstcDescr254"],
      chrstc_descr: row["ChrstcDescr"], chrstc_descrshort: chrstc_descrshort, chrstc: row["Chrstc"])
    if room_char.save
      increment(:created)
    else
      add_error("update_all_classroom_characteristics, error: Could not add #{row["RmRecNbr"]} because : #{room_char.errors.messages}")
      @debug
    end
  end

  def create_classroom_characteristics(characteristics)
    characteristics.each do |row|
      chrstc_descrshort = row["ChrstcDescrShort"].gsub(/[^0-9A-Za-z]/, "")
      room_char = RoomCharacteristic.new(rmrecnbr: row["RmRecNbr"], chrstc_desc254: row["ChrstcDescr254"],
        chrstc_descr: row["ChrstcDescr"], chrstc_descrshort: chrstc_descrshort, chrstc: row["Chrstc"])
      if room_char.save
        increment(:created)
      else
        add_error("update_all_classroom_characteristics, error: Could not create #{row["RmRecNbr"]} because : #{room_char.errors.messages}")
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
    start_result("Update classroom contacts")
    begin
      result = {"success" => false, "errorcode" => "", "error" => "", "data" => {}}
      @debug = false
      classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
      number_of_api_calls_per_minutes = 0
      redo_loop_number = 1
      classrooms.each do |room|
        if number_of_api_calls_per_minutes < NUMBER_OF_API_CALLS
          number_of_api_calls_per_minutes += 1
        else
          add_warning("update_all_classroom_contacts, the script sleeps after #{number_of_api_calls_per_minutes} calls")
          number_of_api_calls_per_minutes = 1
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
        end
        facility_id = room.facility_code_heprod
        rmrecnbr = room.rmrecnbr
        result = get_classroom_contact(ERB::Util.url_encode(facility_id))
        increment(:api_calls)
        if result["errorcode"] == ERROR_CODE_ERR429
          add_warning("update_all_classroom_contacts, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls")
          number_of_api_calls_per_minutes = 0
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
          if redo_loop_number > 9
            add_error("update_all_classroom_contacts, error: API return: #{result["errorcode"]} - #{result["error"]} after #{number_of_api_calls_per_minutes} calls #{redo_loop_number} times ")
            sleep(61.seconds)
            increment(:rate_limit_sleeps)
            return finish_result
          end
          redo_loop_number += 1
          increment(:retries)
          redo
        elsif result["success"]
          if result["data"]["Classroom"].present?
            row = result["data"]["Classroom"][0]
            if RoomContact.find_by(rmrecnbr: rmrecnbr).present?
              update_classroom_contact(row, rmrecnbr)
            else
              create_classroom_contact(row, rmrecnbr)
            end
          else
            increment(:skipped)
            add_warning("update_all_classroom_contacts, No contacts for facility_id #{facility_id}")
          end
        else
          add_error("update_all_classroom_contacts, error: API returns false for facility_id #{facility_id}: #{result["errorcode"]} - #{result["error"]}")
          sleep(61.seconds)
          increment(:rate_limit_sleeps)
          return finish_result
        end
        return finish_result if @debug
      end
    rescue => e
      # example: Errno::ETIMEDOUT: Operation timed out - user specified timeout
      add_error("update_all_classroom_contacts, error: API return: #{e.message}")
      sleep(61.seconds)
      increment(:rate_limit_sleeps)
    end
    finish_result
  end

  def update_classroom_contact(row, rmrecnbr)
    contact = RoomContact.find_by(rmrecnbr: rmrecnbr)
    if contact.update(rm_schd_cntct_name: row["ContactName"], rm_schd_email: row["Email"], rm_schd_cntct_phone: row["Phone"],
      rm_det_url: row["ScheduleURL"], rm_usage_guidlns_url: row["UsageGuideLinesURL"], rm_sppt_deptid: row["SpptDeptID"],
      rm_sppt_cntct_email: row["SpptCntctEmail"], rm_sppt_cntct_phone: row["SpptCntctPhone"], rm_sppt_cntct_url: row["SpptCntctURL"])
      increment(:updated)
    else
      add_error("update_all_classroom_contacts, error: Could not update #{rmrecnbr} because : #{contact.errors.messages}")
      @debug
    end
  end

  def create_classroom_contact(row, rmrecnbr)
    contact = RoomContact.new(rmrecnbr: rmrecnbr, rm_schd_cntct_name: row["ContactName"], rm_schd_email: row["Email"], rm_schd_cntct_phone: row["Phone"],
      rm_det_url: row["ScheduleURL"], rm_usage_guidlns_url: row["UsageGuideLinesURL"], rm_sppt_deptid: row["SpptDeptID"],
      rm_sppt_cntct_email: row["SpptCntctEmail"], rm_sppt_cntct_phone: row["SpptCntctPhone"], rm_sppt_cntct_url: row["SpptCntctURL"])
    if contact.save
      increment(:created)
    else
      add_error("update_all_classroom_contacts, error: Could not create #{rmrecnbr} because : #{contact.errors.messages}")
      @debug
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
      query: {startDate: start_date, endDate: end_date}
    )
    response["data"]
  end

  private

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

  def add_metadata(key, value)
    @last_result&.add_metadata(key, value)
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
