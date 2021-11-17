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


