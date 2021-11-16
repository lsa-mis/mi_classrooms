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
    if room.building.building_image.attached?
      image_tag room.building.building_image, height: '200', width: '200', class: "mr-2""#{room.room_number} --  #{room.building.name}" 
    else
      image_tag 'building_placeholder', height: '100', width: '100', class: "mr-2""#{room.room_number} --  #{room.building.name}" 
    end
  end

end