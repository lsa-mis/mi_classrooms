desc "This will add images to rooms"
task add_images_to_rooms: :environment do

  path_to_images = "/home/deploy/uploads/room_images/"
  images = []
  classrooms = Room.where(rmtyp_description: "Classroom").where.not(facility_code_heprod: nil)
  classrooms_facility_codes = classrooms.pluck(:facility_code_heprod)

  file_names = Dir["/home/deploy/uploads/room_images/*.jpg"].each { |f| images << File.basename(f, ".jpg")}
  room_images = classrooms_facility_codes & images

  room_images.each do |ri|
    room = Room.find_by(facility_code_heprod: ri)
    filename = ri + ".jpg"
    image = path_to_images + filename
    room.room_image.attach(io: File.open(image), filename: filename)
  end
end