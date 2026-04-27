require "rails_helper"

RSpec.describe UpdateRoomCharacteristicsArrayJob, type: :job do
  let(:building) { create(:building, bldrecnbr: 5_000_101) }

  describe "#perform" do
    it "updates room characteristics arrays from matching records" do
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_300_101,
        characteristics: [],
        rmtyp_description: "Classroom",
        facility_code_heprod: "CHAR101",
        instructional_seating_count: 30
      )

      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 1, chrstc_descrshort: "ProjDigit")
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 2, chrstc_descrshort: "DocCam")
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 3, chrstc_descrshort: nil)
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 4, chrstc_descrshort: "DocCam")

      described_class.perform_now

      expect(room.reload.characteristics).to eq(%w[DocCam ProjDigit])
    end

    it "ignores missing rooms without raising an error" do
      distinct_characteristics = instance_double(ActiveRecord::Relation, pluck: [9_999_999])
      allow(RoomCharacteristic).to receive(:distinct).and_return(distinct_characteristics)
      allow(Room).to receive(:find_by).with(rmrecnbr: 9_999_999).and_return(nil)

      expect { described_class.perform_now }.not_to raise_error
    end

    it "clears stale room characteristics arrays when all characteristic rows are removed" do
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_300_102,
        characteristics: %w[DocCam ProjDigit],
        rmtyp_description: "Classroom",
        facility_code_heprod: "CHAR102",
        instructional_seating_count: 30
      )

      described_class.perform_now

      expect(room.reload.characteristics).to eq([])
    end
  end
end
