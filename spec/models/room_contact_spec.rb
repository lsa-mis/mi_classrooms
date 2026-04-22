require "rails_helper"

RSpec.describe RoomContact, type: :model do
  describe "associations" do
    it "belongs to a room" do
      building = create(:building, bldrecnbr: 9_000_101)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_600_101,
        rmtyp_description: "Classroom",
        facility_code_heprod: "RC101",
        instructional_seating_count: 40
      )
      contact = described_class.create!(
        room: room,
        rmrecnbr: room.rmrecnbr,
        rm_schd_cntct_name: "Scheduling Office",
        rm_schd_email: "schedule@umich.edu"
      )

      expect(contact.room).to eq(room)
    end
  end

  describe "validations" do
    it "requires an rmrecnbr" do
      contact = described_class.new(rm_schd_cntct_name: "Scheduling Office")

      expect(contact).not_to be_valid
      expect(contact.errors[:rmrecnbr]).to include("can't be blank")
    end
  end
end
