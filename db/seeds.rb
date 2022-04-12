# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# The following was run on the staging server manualy
# Put here to keep records of these updates
#

locations = ['home_page', 'find_a_room_page', 'about_page']
existing_locations = Announcement.all.pluck(:location)

locations.each do |location|
  unless existing_locations.include?(location)
    Announcement.create!(location: location)
  end
end

# Building.find_by(bldrecnbr: 1000151).update(nick_name: "UMMA")
# Building.find_by(bldrecnbr: 1005046).update(nick_name: "USB")
# Building.find_by(bldrecnbr: 1000165).update(nick_name: "WEIS")
# Building.find_by(bldrecnbr: 1000162).update(nick_name: "DENT")
# Building.find_by(bldrecnbr: 1005235).update(nick_name: "LSSH")
# Building.find_by(bldrecnbr: 1005177).update(nick_name: "NQ")
# Building.find_by(bldrecnbr: 1000440).update(nick_name: "SM")
# Building.find_by(bldrecnbr: 1000054).update(nick_name: "EQ")
# Building.find_by(bldrecnbr: 1000234).update(nick_name: "SPH")
# Building.find_by(bldrecnbr: 1000333).update(nick_name: "400NI")
# Building.find_by(bldrecnbr: 1005101).update(nick_name: "WEILL")
# Building.find_by(bldrecnbr: 1005370).update(nick_name: "BLAU")
# Building.find_by(bldrecnbr: 1000211).update(nick_name: "SKB")
# Building.find_by(bldrecnbr: 1000216).update(nick_name: "TAP")
# Building.find_by(bldrecnbr: 1000207).update(nick_name: "MLB")
# Building.find_by(bldrecnbr: 1005451).update(nick_name: "CCCB")
# Building.find_by(bldrecnbr: 1005188).update(nick_name: "R-BUS")
# Building.find_by(bldrecnbr: 1000158).update(nick_name: "CHEM")
# Building.find_by(bldrecnbr: 1000152).update(nick_name: "AH")
# Building.find_by(bldrecnbr: 1000154).update(nick_name: "LORCH")
# Building.find_by(bldrecnbr: 1000059).update(nick_name: "ALH")
# Building.find_by(bldrecnbr: 1000179).update(nick_name: "HUTCH")
# Building.find_by(bldrecnbr: 1000197).update(nick_name: "MH")
# Building.find_by(bldrecnbr: 1000188).update(nick_name: "NUB")
# Building.find_by(bldrecnbr: 1000221).update(nick_name: "SEB")
# Building.find_by(bldrecnbr: 1000206).update(nick_name: "AH")
# Building.find_by(bldrecnbr: 1000204).update(nick_name: "SPH")
# Building.find_by(bldrecnbr: 1005059).update(nick_name: "WDC")
# Building.find_by(bldrecnbr: 1005347).update(nick_name: "426NI")
# Building.find_by(bldrecnbr: 1000184).update(nick_name: "LLIBS")
# Building.find_by(bldrecnbr: 1005179).update(nick_name: "STB")
# Building.find_by(bldrecnbr: 1000219).update(nick_name: "SSWB")
# Building.find_by(bldrecnbr: 1000150).update(nick_name: "LSA")
# Building.find_by(bldrecnbr: 1000189).update(nick_name: "DANA")
# Building.find_by(bldrecnbr: 1000175).update(nick_name: "HH")
# Building.find_by(bldrecnbr: 1000166).update(nick_name: "EH")
# Building.find_by(bldrecnbr: 1000890).update(nick_name: "PERRY")
# Building.find_by(bldrecnbr: 1005224).update(nick_name: "STAMPS")
# Building.find_by(bldrecnbr: 1000155).update(nick_name: "BMT")
# Building.find_by(bldrecnbr: 1000167).update(nick_name: "WH")
# Building.find_by(bldrecnbr: 1005169).update(nick_name: "BSB")
# Building.find_by(bldrecnbr: 1005047).update(nick_name: "PALM")
# Building.find_by(bldrecnbr: 1000208).update(nick_name: "RAND")

# Room.find_by(rmrecnbr: 2020239).update(ada_seat_count: 1)
# Room.find_by(rmrecnbr: 2113853).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2017506).update(ada_seat_count: 3)
# Room.find_by(rmrecnbr: 2017509).update(ada_seat_count: 8)
# Room.find_by(rmrecnbr: 2017518).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2017526).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2017624).update(ada_seat_count: 10)
# Room.find_by(rmrecnbr: 2020228).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2026595).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2031968).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2031973).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2031976).update(ada_seat_count: 8)
# Room.find_by(rmrecnbr: 2031981).update(ada_seat_count: 8)
# Room.find_by(rmrecnbr: 2032110).update(ada_seat_count: 6)
# Room.find_by(rmrecnbr: 2032118).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2032119).update(ada_seat_count: 3)
# Room.find_by(rmrecnbr: 2032133).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2019609).update(ada_seat_count: 2)
# # Room.find_by(rmrecnbr: 2043027).update(ada_seat_count: 2)
# Room.find_by(rmrecnbr: 2020098).update(ada_seat_count: 3)
# Room.find_by(rmrecnbr: 2186754).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2016322).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2117778).update(ada_seat_count: 4)
# Room.find_by(rmrecnbr: 2117781).update(ada_seat_count: 5)

# Room.find_by(facility_code_heprod: "MLB1200").update(nickname: 'Aud 3')
# Room.find_by(facility_code_heprod: "MLB1220").update(nickname: 'Lec 1')
# Room.find_by(facility_code_heprod: "MLB1400").update(nickname: 'Aud 4')
# Room.find_by(facility_code_heprod: "MLB1420").update(nickname: 'Lec 2')