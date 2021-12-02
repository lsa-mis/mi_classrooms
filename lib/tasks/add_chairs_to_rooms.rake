desc "This will add chair layouts to rooms"
task add_chairs_to_rooms: :environment do

  path_to_images = "/home/deploy/uploads/chair_charts/"
  images = []
  classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
  classrooms_facility_codes = classrooms.pluck(:facility_code_heprod)

  file_names = Dir["/home/deploy/uploads/chair_charts/*.pdf"].each { |f| images << File.basename(f, ".pdf").split("_chairs")[0]}
  room_images = classrooms_facility_codes & images

  room_images.each do |ri|
    room = Room.find_by(facility_code_heprod: ri)
    filename = ri + "_chairs.pdf"
    image = path_to_images + filename
    room.room_layout.attach(io: File.open(image), filename: filename)
  end
end