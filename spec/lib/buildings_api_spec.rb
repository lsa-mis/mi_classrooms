require "rails_helper"

RSpec.describe BuildingsApi do
  describe "#update_building" do
    it "uses the same country value as newly created buildings" do
      campus = CampusRecord.create!(campus_cd: 100, campus_description: "Ann Arbor")
      building = create(:building, bldrecnbr: 5_000_301, country: "old")
      api = described_class.new
      api.instance_variable_set(:@buildings_ids, [building.bldrecnbr])

      api.update_building(
        "BuildingRecordNumber" => building.bldrecnbr.to_s,
        "BuildingLongDescription" => "Updated Building",
        "BuildingShortDescription" => "UB",
        "BuildingStreetNumber" => "123",
        "BuildingStreetDirection" => "",
        "BuildingStreetName" => "State Street",
        "BuildingCity" => "Ann Arbor",
        "BuildingState" => "MI",
        "BuildingPostal" => "48109",
        "BuildingCampusCode" => campus.campus_cd.to_s
      )

      expect(building.reload.country).to eq("USA")
    end
  end

  describe "#delete_stale_rooms" do
    it "rolls back related deletes when every requested room is not deleted" do
      building = create(:building, bldrecnbr: 5_000_302)
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1_500_302)
      contact = RoomContact.create!(rmrecnbr: room.rmrecnbr)
      characteristic = create(:room_characteristic, rmrecnbr: room.rmrecnbr)
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr, 9_999_999])

      expect(api.send(:delete_stale_rooms, "update_rooms")).to be(false)
      expect(Room.exists?(room.rmrecnbr)).to be(true)
      expect(RoomContact.exists?(contact.id)).to be(true)
      expect(RoomCharacteristic.exists?(characteristic.id)).to be(true)
    end
  end
end
