require "csv"
require "benchmark"

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

class RoomContactsImporter
  HEADER_MAP = {"RMRECNBR" => :rmrecnbr,
                "RM_SCHD_CNTCT_NAME" => :rm_schd_cntct_name,
                "RM_SCHD_EMAIL" => :rm_schd_email,
                "RM_SCHD_CNTCT_PHONE" => :rm_schd_cntct_phone,
                "RM_DET_URL" => :rm_det_url,
                "RM_USAGE_GUIDLNS_URL" => :rm_usage_guidlns_url,
                "RM_SPPT_DEPTID" => :rm_sppt_deptid,
                "RM_SPPT_DEPT_DESCR" => :rm_sppt_dept_descr,
                "RM_SPPT_CNTCT_EMAIL" => :rm_sppt_cntct_email,
                "RM_SPPT_CNTCT_PHONE" => :rm_sppt_cntct_phone,
                "RM_SPPT_CNTCT_URL" => :rm_sppt_cntct_url,}.freeze

  def initialize
    @rooms = Room.pluck(:rmrecnbr).uniq
    file = find_file("uploads/room_contacts.csv")
    room_contacts = load_room_contacts_from_csv(file)
  end

  def room_contacts_logger
    @@room_contacts_logger ||= Logger.new("#{Rails.root}/log/room_contacts_importer.log")
  end

  def load_room_contacts_from_csv(file)
    @room_contacts = []
    CSV.foreach(file, headers: true, header_converters: lambda { |header| HEADER_MAP[header] }) do |row|
      puts row
      # room_contact << row.to_h
      room_contact = create_valid_room_contact(row).to_h
      if room_exists?(room_contact[:rmrecnbr])
        @room_contacts << room_contact
      end
    end
    import_room_contacts(@room_contacts)
  end

  
  def create_valid_room_contact(room_contact)
    room_contact[:rmrecnbr] = room_contact[:rmrecnbr].to_i
    room_contact[:rm_schd_cntct_name] = room_contact[:rm_schd_cntct_name]
    room_contact[:rm_schd_email] = room_contact[:rm_schd_email]
    room_contact[:rm_schd_cntct_phone] = room_contact[:rm_schd_cntct_phone]
    room_contact[:rm_det_url] = room_contact[:rm_det_url]
    room_contact[:rm_sppt_deptid] = room_contact[:rm_sppt_deptid]
    room_contact[:rm_sppt_dept_descr] = room_contact[:rm_sppt_dept_descr]
    room_contact[:rm_sppt_cntct_email] = room_contact[:rm_sppt_cntct_email]
    room_contact[:rm_sppt_cntct_phone] = room_contact[:rm_sppt_cntct_phone]
    room_contact[:rm_sppt_cntct_url] = room_contact[:rm_sppt_cntct_url]
    room_contact[:created_at] = Time.now
    room_contact[:updated_at] = Time.now
    room_contact = room_contact.select {|k, v| !k.blank?}

  end

  def import_room_contacts(room_contacts)
    RoomContact.delete_all
    room_contacts.each do |rc|
      RoomContact.create(create_valid_room_contact(rc))
    end
    # RoomContact.upsert_all(room_contacts)
  end

  def find_file(file)
    Rails.root.join(file)
  end

  def room_exists?(rmrecnbr)
    @rooms.include?(rmrecnbr.to_i)
  end
end
