class OracleDatabase

  def initialize(oci8_db)
    @oci8_db = oci8_db
  end

  def building_logger
      @@building_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_building_update.log")
    end
  
  def room_logger
    @@room_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_room_update.log")
  end

  def classroom_characteristics_logger
    @@classroom_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_classroom_characteristics_update.log")
  end

  def contact_logger
    @@contact_logger ||= Logger.new("#{Rails.root}/log/#{Date.today}_classroom_contacts_update.log")
  end

  def update_all_buildings(campus_codes, buildings_codes)
    sql = "SELECT
        BLDRECNBR,
        BLD_DESCRSHORT,
        BLD_DESCR50,
        BLDSTREETNBR,
        BLDSTREETDIR,
        BLDSTREETNAME,
        BLDCITY,
        BLDSTATE,
        BLDPOSTAL,
        BLDCOUNTRY,
        BLDCAMPUSCD
      FROM M_SMDW2.BLD_TBL b
      WHERE 
        b.FISCAL_YEAR = 
        (SELECT max(b1.FISCAL_YEAR)
        FROM M_SMDW2.BLD_TBL b1
        )
        AND (BLDCAMPUSCD IN (" + "'#{campus_codes.join("', '")}'" + ")
            OR BLDRECNBR IN (" + buildings_codes.join(", ") + "))
        "
    # puts sql
    
    result = []
    @oci8_db.exec(sql) do |r| 
      result << r.join(';'); 
    end
    @buildings_ids = Building.all.pluck(:bldrecnbr)
    result.each do |r|
      row = r.split(';')
      bldrecnbr = row[0].to_i
      if building_exists?(bldrecnbr)
        update_building(bldrecnbr, row)
      else
        create_building(bldrecnbr, row)
      end
    end
  end

  def building_exists?(bldrecnbr)
    @buildings_ids.include?(bldrecnbr)
  end

  def update_building(bldrecnbr, row)
    building = Building.find_by(bldrecnbr: bldrecnbr)
    if building.update(name: row[2], nick_name: row[2], abbreviation: row[1], 
          address: " #{row[3]}  #{row[4]}  #{row[5]}".strip.gsub(/\s+/, " "), 
          city: row[6], state: row[7], zip: row[8], country: row[9], 
          campus_record_id: CampusRecord.find_by(campus_cd: row[10].to_i).id)
      @buildings_ids.delete(bldrecnbr)
    else
      building_logger.info "Could not update #{bldrecnbr} because : #{building.errors.messages}"
    end
  end

  def create_building(bldrecnbr, row)
    building = Building.new(bldrecnbr: bldrecnbr, name: row[2], nick_name: row[2], abbreviation: row[1], 
    address: " #{row[3]}  #{row[4]}  #{row[5]}".strip.gsub(/\s+/, " "), 
    city: row[6], state: row[7], zip: row[8], country: row[9], 
    campus_record_id: CampusRecord.find_by(campus_cd: row[10].to_i).id)

    if building.save
      GeocodeBuildingJob.perform_later(building)
    else
      building_logger.info "Could not create #{bldrecnbr} because : #{building.errors.messages}"
    end
  end

  def update_rooms
    buildings_ids = Building.all.pluck(:bldrecnbr)
    @rooms_in_db = Room.all.pluck(:rmrecnbr)
    @rooms_not_updated = []
    sql = "SELECT
          r.rmrecnbr, r.floor, r.rmnbr, r.rmsqrft, r.rmtyp_descr50, f.rm_inst_seat_cnt,
          d.deptid, d.dept_descr, d.dept_grp, d.dept_grp_descr,
          r.bldrecnbr, r.bld_descr50,
          nvl(f.facility_id, 'no match') AS facility_id
        FROM
          m_smdw2.rm_tbl r
          INNER JOIN m_gldw1.curr_fn_dept_vw d ON r.deptid = d.deptid
          LEFT OUTER JOIN (
              SELECT
                  f.facility_id,
                  f.facility_eff_status,
                  f.rmrecnbr,
                  f.rm_inst_seat_cnt
              FROM
                  m_srdw1.facility_tbl f
              WHERE
                  f.facility_effdt = (
                      SELECT
                          MAX(f1.facility_effdt)
                      FROM
                          m_srdw1.facility_tbl f1
                      WHERE
                          f1.facility_id = f.facility_id
                          AND f1.facility_effdt <= SYSDATE
                          AND (f.facility_eff_status = 'A')
                  )
          ) f ON r.rmrecnbr = f.rmrecnbr
        WHERE
          r.fiscal_year = (
              SELECT
                  MAX(r1.fiscal_year)
              FROM
                  m_smdw2.rm_tbl r1
          )
          AND r.bldrecnbr IN (" + buildings_ids.join(", ") + ")
          "
          # puts sql
    result = []
    @oci8_db.exec(sql) do |r| 
      result << r.join(';'); 
    end
    result.each do |r|
      row = r.split(';')
      rmrecnbr = row[0].to_i
      if room_exists?(rmrecnbr)
        update_room(rmrecnbr, row)
      else
        create_room(rmrecnbr, row)
      end
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
  end

  def room_exists?(rmrecnbr)
    Room.find_by(rmrecnbr: rmrecnbr).present?
  end

  def update_room(rmrecnbr,row)
    if row[12] == "no match"
      facility_id = nil
    else 
      facility_id = row[12]
    end
    room = Room.find_by(rmrecnbr: row[0])
    if room.update(floor: row[1], room_number: row[2], 
            square_feet: row[3].to_i, rmtyp_description: row[4],
            instructional_seating_count: row[5].to_i, dept_id: row[6].to_i, dept_description: row[7],
            dept_grp: row[8], dept_group_description: row[9],
            building_bldrecnbr: row[10].to_i, building_name: row[11],
            facility_code_heprod: facility_id,
            campus_record_id: Building.find_by(bldrecnbr: row[10].to_i).campus_record_id)
      @rooms_in_db.delete(rmrecnbr)
    else
      room_logger.info "Could not update #{rmrecnbr} because : #{room.errors.messages}"
    end
  end

  def create_room(rmrecnbr, row)
    if row[12] == "no match"
      facility_id = nil
    else 
      facility_id = row[12]
    end
    room = Room.new(rmrecnbr: rmrecnbr, floor: row[1], room_number: row[2], 
        square_feet: row[3], rmtyp_description: row[4],
        instructional_seating_count: row[5], dept_id: row[6], dept_description: row[7],
        dept_grp: row[8], dept_group_description: row[9],
        building_bldrecnbr: row[10], building_name: row[11],
        facility_code_heprod: facility_id,
        campus_record_id: Building.find_by(bldrecnbr: row[10]).campus_record_id, visible: true)

    unless room.save
      room_logger.info "Could not create #{rmrecnbr} because : #{room.errors.messages}"
    end
  end

  def update_classroom_characteristics
    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil).pluck(:rmrecnbr)
    sql = "SELECT
        r.RMRECNBR, r.CHRSTC,
        c.CHRSTC_EFF_STATUS, c.CHRSTC_DESCR, c.CHRSTC_DESCRSHORT,
        c.CHRSTC_DESCR254
      FROM
        m_smdw2.rmchrstc_tbl r,
        m_smdw2.chrstcdef_tbl c
      WHERE
        r.CHRSTC = c.CHRSTC
        and r.FISCAL_YEAR = c.FISCAL_YEAR
        and r.FISCAL_YEAR =
          (SELECT max(fiscal_year) FROM m_smdw2.rmchrstc_tbl)
          AND r.RMRECNBR IN (" + classrooms.join(", ") + ")
          "
    # puts sql

    result = []
    @oci8_db.exec(sql) do |r| 
      result << r.join(';'); 
    end
    RoomCharacteristic.destroy_all
    result.each do |r|
      row = r.split(';')
      r0 = row[0]
      rmrecnbr = r0.to_i
      create_classroom_characteristics(rmrecnbr, row)
    end

  end

  def create_classroom_characteristics(rmrecnbr, row)
      room_char = RoomCharacteristic.new(rmrecnbr: rmrecnbr, chrstc: row[1], chrstc_eff_status: row[2], 
                  chrstc_descr: row[3], chrstc_descrshort: row[4], chrstc_desc254: row[5])
      unless room_char.save
        classroom_characteristics_logger.debug "Could not create #{rmrecnbr} because : #{room_char.errors.messages}"
      end

  end

  def update_classroom_contacts
    classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil).pluck(:rmrecnbr)
    sql = "SELECT
    RMRECNBR, RM_SCHD_CNTCT_NAME, RM_SCHD_EMAIL, RM_SCHD_CNTCT_PHONE,
    RM_DET_URL, RM_USAGE_GUIDLNS_URL,
    RM_SPPT_DEPTID, RM_SPPT_DEPT_DESCR, RM_SPPT_CNTCT_EMAIL, RM_SPPT_CNTCT_PHONE, RM_SPPT_CNTCT_URL
      FROM
        m_smdw2.rm_schd_cntct_info
      WHERE FISCAL_YEAR =
        (SELECT max(fiscal_year) FROM m_smdw2.rm_schd_cntct_info)
        AND RMRECNBR IN (" + classrooms.join(", ") + ")
        "
    result = []
    @oci8_db.exec(sql) do |r| 
      result << r.join(';'); 
    end
    result.each do |r|
      row = r.split(';')
      rmrecnbr = row[0].to_i
      if RoomContact.find_by(rmrecnbr: rmrecnbr).present?
        update_classroom_contact(rmrecnbr, row)
      else
        create_classroom_contact(rmrecnbr, row)
      end
    end
  end

  def update_classroom_contact(rmrecnbr, row)
    contact = RoomContact.find_by(rmrecnbr: rmrecnbr)
    unless contact.update(rm_schd_cntct_name: row[1], rm_schd_email: row[2], rm_schd_cntct_phone: row[3],
                rm_det_url: row[4], rm_usage_guidlns_url: row[5], rm_sppt_deptid: row[6], rm_sppt_dept_descr: row[7],
                rm_sppt_cntct_email: row[8], rm_sppt_cntct_phone: row[9], rm_sppt_cntct_url: row[10])
      contact_logger.debug "Could not update #{rmrecnbr} because : #{contact.errors.messages}"
    end
  end

  def create_classroom_contact(rmrecnbr, row)
    contact = RoomContact.new(rmrecnbr: rmrecnbr, rm_schd_cntct_name: row[1], rm_schd_email: row[2], rm_schd_cntct_phone: row[3],
    rm_det_url: row[4], rm_usage_guidlns_url: row[5], rm_sppt_deptid: row[6], rm_sppt_dept_descr: row[7],
    rm_sppt_cntct_email: row[8], rm_sppt_cntct_phone: row[9], rm_sppt_cntct_url: row[10])
    unless contact.save
      contact_logger.debug "Could not create #{rmrecnbr} because : #{contact.errors.messages}"
    end
  end

end