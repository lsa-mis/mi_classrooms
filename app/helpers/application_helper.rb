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
      image_tag 'building_placeholder', class: 'max-h-20 p-2', alt: "building placeholder" 
    end
  end

  def room_image( room )
    if room.room_image.representable?
      image_tag room.room_image.representation(resize_to_limit: [1000, 800]), class: 'h-96  p-2', alt: "#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'room_placeholder.png', class: 'max-h-24 p-2', alt: "The image for this room is not available"
    end
  end



  def room_thumbnail_image( room )
    if room.room_image.representable?
      image_tag room.room_image.representation(resize_to_limit: [1000, 800]), class: 'max-h-24 p-2', alt: "#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'room_placeholder', class: 'max-h-24 p-2', alt: "room placeholder" 
    end
  end

  def room_layout( room )
    if room.room_layout.representable?
      room.room_layout
    else
      "#"
    end
  end

  def room_panorama( room )
    if room.room_panorama.representable?
      room.room_panorama
    else
      "#"
    end
  end

  def api_status
    if ApiUpdateLog.find_by(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).nil?
      return "failed"
    elsif ApiUpdateLog.find_by(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).status == "error"
      return 'error'
    end
  end

  def api_log_text
    if ApiUpdateLog.find_by(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).result.present?
      ApiUpdateLog.find_by(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day).result
    else
      "The log message is empty"
    end
  end


end

