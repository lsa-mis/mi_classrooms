require "csv"
require "benchmark"
require "active_record"

CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

class RoomCharacteristicsImporter
  HEADER_MAP = {"RMRECNBR" => :rmrecnbr,
                "CHRSTC" => :chrstc,
                "CHRSTC_EFF_STATUS" => :chrstc_eff_status,
                "CHRSTC_DESCRSHORT" => :chrstc_descrshort,
                "CHRSTC_DESCR" => :chrstc_descr,
                "CHRSTC_DESCR254" => :chrstc_desc254,}.freeze

  def initialize
    @classrooms = Room.pluck(:rmrecnbr).uniq
    file = find_file("uploads/room_characteristics.csv")
    room_characteristics = load_room_characteristics_from_csv(file)
  end

  def room_characteristics_logger
    @@room_characteristics_logger ||= Logger.new("#{Rails.root}/log/room_characteristics_importer.log")
  end

  def load_room_characteristics_from_csv(file)
    @room_characteristics = []
    CSV.foreach(file, headers: true, header_converters: lambda { |header| HEADER_MAP[header] }) do |row|
      room_characteristic = create_valid_room_characteristic(row).to_h
      if room_exists?(room_characteristic[:rmrecnbr])
        @room_characteristics << room_characteristic
      end

    end
    import_room_characteristics(@room_characteristics)
  end

  def create_valid_room_characteristic(room_characteristic)
    room_characteristic[:rmrecnbr] = room_characteristic[:rmrecnbr].to_i
    room_characteristic[:chrstc] = room_characteristic[:chrstc]
    room_characteristic[:chrstc_eff_status] = room_characteristic[:chrstc_eff_status]
    room_characteristic[:chrstc_descrshort] = room_characteristic[:chrstc_descrshort]
    room_characteristic[:chrstc_descr] = room_characteristic[:chrstc_descr]
    room_characteristic[:chrstc_desc254] = room_characteristic[:chrstc_desc254]
    room_characteristic[:created_at] = Time.now
    room_characteristic[:updated_at] = Time.now
    room_characteristic = room_characteristic.select {|k, v| !k.blank?}

  end

  def import_room_characteristics(room_characteristics)
    RoomCharacteristic.delete_all
    RoomCharacteristic.upsert_all(room_characteristics)
  end

  def find_file(file)
    Rails.root.join(file)
  end

  def room_exists?(rmrecnbr)
    @classrooms.include?(rmrecnbr.to_i)
  end

end
