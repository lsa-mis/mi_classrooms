# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

locations = ['index_page', 'rooms_page']
existing_locations = Announcement.all.pluck(:location)

locations.each do |location|
  unless existing_locations.include?(location)
    Announcement.create!(location: location)
  end
end
