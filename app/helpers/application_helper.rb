module ApplicationHelper
  include Pagy::Frontend

  # Returns the full title on a per-page basis.
  def page_title
    base_title = (t :site_name)
    if @page_title.nil?
      "#{params[:controller].capitalize} | " + base_title
    else
      "#{@page_title} | #{base_title}"
    end
  end

  def svg(svg)
    file_path = "app/packs/images/svgs/#{svg}.svg"
    return File.read(file_path).html_safe if File.exist?(file_path)
    file_path
  end

  def building_image( room )
    if room.building.building_image.representable?
      image_tag room.building.building_image.representation(resize_to_limit: [150, 150]), class: 'm-2', alt: "#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'building_placeholder', height: '150', width: '150', class: 'mr-2', alt: "building placeholder" 
    end
  end

  def room_image( room )
    if room.room_image.representable?
      image_tag room.room_image.representation(resize_to_limit: [600, 400]), class: 'm-2', alt: "#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'room_placeholder', height: '150', width: '150', class: 'mr-2', alt: "room placeholder" 
    end
  end

  def room_thumbnail_image( room )
    if room.room_image.representable?
      image_tag room.room_image.representation(resize_to_limit: [100, 80]), class: 'p-2', alt: "#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'room_placeholder', height: '75', width: '100', class: 'p-2', alt: "room placeholder" 
    end
  end

  ROOM_CHARACTERISTIC_NAME = {
    "InstrComp" => "Instructor Computer",
    "DocCam" => "Document Camera",
    "LectureCap" => "Lecture Capture",
    "VideoConf" => "Video Conferencing",
    "IntrScreen" => "Interactive Screen",
    "BluRay" => "BluRay / DVD",
    "TeamBoard" => "Team Board",
    "TeamTables" => "Team Tables",
    "TeamTech" => "Team Technology",
    "Whtbrd" => "Whiteboard",
    "Chkbrd" => "Chalkboard",
    "Proj35mm" => "35mm Film",
    "ProjD-Cin" => "Digital Cinema (DCP)",
    "ProjDigit" => "Digital Data & Video"
  }

end

