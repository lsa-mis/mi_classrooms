require "rails_helper"

RSpec.describe ClassroomApi do
  describe "#add_facility_id_to_classrooms" do
    it "reports stale classroom deletions without deleting rows when delete dry run is enabled" do
      building = create(:building, bldrecnbr: 5_000_201)
      classroom = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_201,
        rmtyp_description: "Classroom"
      )
      office = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_202,
        rmtyp_description: "Office"
      )
      api = described_class.new(delete_dry_run: true)

      allow(api).to receive(:get_classrooms_list).and_return(
        "success" => true,
        "data" => []
      )

      expect(api.add_facility_id_to_classrooms).to be(false)
      expect(Room.exists?(classroom.rmrecnbr)).to be(true)
      expect(Room.exists?(office.rmrecnbr)).to be(true)
      expect(api.last_result.counters[:would_delete]).to eq(1)
      expect(api.last_result.warnings.join).to include("dry run")
    end
  end

  describe "#deactivate_stale_rooms" do
    it "rolls back deactivation when every requested room is not deactivated" do
      building = create(:building, bldrecnbr: 5_000_202)
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1_400_203)
      contact = RoomContact.create!(rmrecnbr: room.rmrecnbr)
      characteristic = create(:room_characteristic, rmrecnbr: room.rmrecnbr)
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr, 9_999_999])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to be(false)
      expect(Room.exists?(room.rmrecnbr)).to be(true)
      expect(RoomContact.exists?(contact.id)).to be(true)
      expect(RoomCharacteristic.exists?(characteristic.id)).to be(true)
    end
  end
end
