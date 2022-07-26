module SearchHelper

  ROOM_CHARACTERISTIC_ICONS = {
    "AssistLis" => "assistive-listening-systems",
    "AudSeat" => "chair",
    "Blackout" => "lightbulb",
    "BluRay" => "compact-disc",
    "BluRayDVD" => "compact-disc",
    "CaptionDev" => "closed-captioning",
    "Carpet" => "info-circle",
    "ChairFix" => "chair",
    "Chkbrd" => "chalkboard-teacher",
    "Chkbrd25" => "chalkboard-teacher",
    "CompLabAny" => "keyboard",
    "CompLabMac" => "keyboard",
    "CompLabPC" => "keyboard",
    "CompPodMac" => "apple",
    "DocCam" => "microscope",
    "Ethernet" => "ethernet",
    "EthrStud" => "ethernet",
    "FloorTier" => "info-circle",
    "InstrComp" => "laptop",
    "IntrScreen" => "edit",
    "LectureCap" => "podcast",
    "MoveTablet" => "info-circle",
    "Platform" => "info-circle",
    "PowerStud" => "plug",
    "Proj16mm" => "film",
    "Proj35mm" => "film",
    "ProjD-Cin" => "video",
    "ProjDigit" => "video",
    "ProjSlide" => "photo-video",
    "SoundPrgrm" => "volume-up",
    "SoundVoice" => "headset",
    "Stage" => "info-circle",
    "TablesAny" => "info-circle",
    "TablesConf" => "info-circle",
    "TablesFix" => "info-circle",
    "TablesMov" => "info-circle",
    "TeamBoard" => "users",
    "TeamTables" => "info-circle",
    "TeamTech" => "code-branch",
    "Telephone" => "phone",
    "Tile" => "info-circle",
    "VCR" => "info-circle",
    "VideoConf" => "satellite",
    "WCInst" => "wheelchair",
    "Whtbrd" => "chalkboard-teacher",
    "Whtbrd25" => "chalkboard-teacher",
    "Windows" => "window-close",
    "Wood" => "info-circle",
    "Default" => "info-circle"
  }

  def is_checked?(values)
    if params[:room_characteristics]
      values.each do |value|
        params[:room_characteristics].each_value { |k| k }.flatten(2).include?  (value)
      end
    end
  end


  def capacity_slider_minimum
    if params[:min_capacity]
      if params[:min_capacity]
        params[:min_capacity]
      else
        1
      end
      else
      1
    end
  end
  def capacity_slider_maximum
    if params[:building_name]
      if params[:max_capacity]
        params[:max_capacity]
      else
        600
      end
    else
      600
    end
  end

  def room_characteristic_icon(room_characteristic)
    if ROOM_CHARACTERISTIC_ICONS[room_characteristic.chrstc_descrshort]
      "#{ROOM_CHARACTERISTIC_ICONS[room_characteristic.chrstc_descrshort]}"
    else
      "#{ROOM_CHARACTERISTIC_ICONS['Default']}"
    end
  end
end