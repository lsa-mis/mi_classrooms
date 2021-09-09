class RoomCharacteristicDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  ROOM_CHARACTERISTIC_ICONS = {
    "AssistLis" => "fas fa-assistive-listening-systems",
    "AudSeat" => "fas fa-chair",
    "Blackout" => "far fa-lightbulb",
    "BluRay" => "fas fa-compact-disc",
    "BluRay/DVD" => "fas fa-compact-disc",
    "CaptionDev" => "fas fa-closed-captioning",
    "Carpet" => "fas fa-info-circle",
    "ChairFix" => "fas fa-chair",
    "Chkbrd" => "fas fa-chalkboard-teacher",
    "Chkbrd>25" => "fas fa-chalkboard-teacher",
    "CompLabAny" => "fas fa-keyboard",
    "CompLabMac" => "fas fa-keyboard",
    "CompLabPC" => "fas fa-keyboard",
    "CompPodMac" => "fab fa-apple",
    "DocCam" => "fas fa-microscope",
    "Ethernet" => "fas fa-ethernet",
    "EthrStud" => "fas fa-ethernet",
    "FloorTier" => "fas fa-info-circle",
    "InstrComp" => "fas fa-laptop",
    "IntrScreen" => "fas fa-edit",
    "LectureCap" => "fas fa-podcast",
    "MoveTablet" => "fas fa-info-circle",
    "Platform" => "fas fa-info-circle",
    "PowerStud" => "fas fa-plug",
    "Proj16mm" => "fas fa-film",
    "Proj35mm" => "fas fa-film",
    "ProjD-Cin" => "fas fa-video",
    "ProjDigit" => "fas fa-video",
    "ProjSlide" => "fas fa-photo-video",
    "SoundPrgrm" => "fas fa-volume-up",
    "SoundVoice" => "fas fa-headset",
    "Stage" => "fas fa-info-circle",
    "TablesAny" => "fas fa-info-circle",
    "TablesConf" => "fas fa-info-circle",
    "TablesFix" => "fas fa-info-circle",
    "TablesMov" => "fas fa-info-circle",
    "TeamBoard" => "fas fa-users",
    "TeamTables" => "fas fa-info-circle",
    "TeamTech" => "fas fa-code-branch",
    "Telephone" => "fas fa-phone",
    "Tile" => "fas fa-info-circle",
    "VCR" => "fas fa-info-circle",
    "VideoConf" => "fas fa-satellite",
    "WCInst" => "fas fa-wheelchair",
    "Whtbrd" => "fas fa-chalkboard-teacher",
    "Whtbrd>25" => "fas fa-chalkboard-teacher",
    "Windows" => "fas fa-window-close",
    "Wood" => "fas fa-info-circle",
  }

  def characteristic_icon
    ROOM_CHARACTERISTIC_ICONS[object.chrstc_descrshort]
  end

  def characteristic_label
    # case object
    if object.chrstc_descr.blank?
      "missing"
    elsif object.chrstc_descr.start_with?("Board:")
      object.chrstc_descr.gsub(/^Board:/, "")
    elsif object.chrstc_descr.start_with?("Blackout:")
      object.chrstc_descr.gsub(/^Blackout:/, "")
    elsif object.chrstc_descr.start_with?("Computer Lab:")
      object.chrstc_descr.sub(/^Computer Lab:/, "")
    elsif object.chrstc_descr.start_with?("Projection:")
      object.chrstc_descr.sub(/^Projection:/, "")
    elsif object.chrstc_descr.start_with?("Ethernet Connection:")
      object.chrstc_descr.sub(/^Ethernet Connection:/, "Ethernet:")
    elsif object.chrstc_descr.start_with?("Equipment:")
      object.chrstc_descr.sub(/^Equipment:/, "")
    elsif object.chrstc_descr.start_with?("Floor:")
      object.chrstc_descr.sub(/^Floor:/, "")
    elsif object.chrstc_descr.start_with?("Layout:")
      object.chrstc_descr.sub(/^Layout:/, "")
    elsif object.chrstc_descr.start_with?("Seating:")
      object.chrstc_descr.sub(/^Seating:/, "")
    elsif object.chrstc_descr.start_with?("Sound Amplification:")
      object.chrstc_descr.sub(/^Sound Amplification:/, "Amplification")
    elsif object.chrstc_descr.start_with?("Wheelchair Access:")
      object.chrstc_descr.sub(/^Wheelchair Access: Instructor/, "Wheelchair Access: Instructor")
    else
      object.chrstc_descr
    end
  end
end
