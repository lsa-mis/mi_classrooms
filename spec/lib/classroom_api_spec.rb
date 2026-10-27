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
    it "hides stale classrooms without destroying them or their media" do
      building = create(:building, bldrecnbr: 5_000_204)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_204,
        rmtyp_description: "Classroom",
        visible: true
      )
      contact = RoomContact.create!(rmrecnbr: room.rmrecnbr)
      characteristic = create(:room_characteristic, rmrecnbr: room.rmrecnbr)
      room.room_image.attach(io: StringIO.new("fake image"), filename: "room.png", content_type: "image/png")
      room.room_panorama.attach(io: StringIO.new("fake pano"), filename: "pano.png", content_type: "image/png")
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to eq(1)
      expect(room.reload.visible).to be(false)
      expect(Room.exists?(room.rmrecnbr)).to be(true)
      expect(RoomContact.exists?(contact.id)).to be(true)
      expect(RoomCharacteristic.exists?(characteristic.id)).to be(true)
      expect(room.room_image).to be_attached
      expect(room.room_panorama).to be_attached
    end

    it "rolls back deactivation when every requested room is not deactivated" do
      building = create(:building, bldrecnbr: 5_000_202)
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1_400_203)
      contact = RoomContact.create!(rmrecnbr: room.rmrecnbr)
      characteristic = create(:room_characteristic, rmrecnbr: room.rmrecnbr)
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr, 9_999_999])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to be(false)
      expect(room.reload.visible).to be(true)
      expect(Room.exists?(room.rmrecnbr)).to be(true)
      expect(RoomContact.exists?(contact.id)).to be(true)
      expect(RoomCharacteristic.exists?(characteristic.id)).to be(true)
    end

    it "counts an already hidden classroom as deactivated" do
      building = create(:building, bldrecnbr: 5_000_205)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_205,
        rmtyp_description: "Classroom",
        visible: false
      )
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to eq(0)
      expect(room.reload.visible).to be(false)
    end

    it "hides the visible classrooms when some listed classrooms are already hidden" do
      building = create(:building, bldrecnbr: 5_000_206)
      hidden_room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_206,
        rmtyp_description: "Classroom",
        visible: false
      )
      visible_room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_207,
        rmtyp_description: "Classroom",
        visible: true
      )
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [hidden_room.rmrecnbr, visible_room.rmrecnbr])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to eq(1)
      expect(hidden_room.reload.visible).to be(false)
      expect(visible_room.reload.visible).to be(false)
    end

    it "locks the listed classrooms before counting hidden classrooms" do
      building = create(:building, bldrecnbr: 5_000_209)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_209,
        rmtyp_description: "Classroom",
        visible: true
      )
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr])
      queries = []
      callback = lambda do |_name, _start, _finish, _id, payload|
        queries << payload[:sql]
      end

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")
      end

      lock_index = queries.index { |sql| sql.include?("FOR UPDATE") }
      update_index = queries.index { |sql| sql.match?(/UPDATE "rooms"/) }
      expect(lock_index).to be < update_index
    end
  end

  describe "#update_all_classroom_characteristics" do
    def characteristic_row(rmrecnbr, chrstc, short_code: "ProjDigit")
      {
        "RmRecNbr" => rmrecnbr.to_s,
        "Chrstc" => chrstc.to_s,
        "ChrstcDescr254" => "Digital projector",
        "ChrstcDescr" => "Projection:Digital",
        "ChrstcDescrShort" => short_code
      }
    end

    def stub_characteristics(api, payloads)
      allow(api).to receive(:get_classroom_characteristics) do |facility_id|
        {
          "success" => true,
          "errorcode" => "",
          "error" => "",
          "data" => {"Classroom" => payloads.fetch(facility_id)}
        }
      end
    end

    it "stores one characteristic when the API repeats the same chrstc" do
      building = create(:building, bldrecnbr: 5_000_510)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 2_324_309,
        rmtyp_description: "Classroom",
        facility_code_heprod: "LAW2170"
      )
      api = described_class.new
      stub_characteristics(
        api,
        "LAW2170" => [
          characteristic_row(room.rmrecnbr, 42),
          characteristic_row(room.rmrecnbr, 42)
        ]
      )

      expect(api.update_all_classroom_characteristics).to be(false)
      expect(api.last_result).to be_success
      expect(api.last_result.errors).to be_empty
      expect(RoomCharacteristic.where(rmrecnbr: room.rmrecnbr, chrstc: 42).count).to eq(1)
      expect(api.last_result.counters[:created]).to eq(1)
    end

    it "keeps syncing later rooms when a repeated characteristic is already stored" do
      building = create(:building, bldrecnbr: 5_000_511)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 2_324_310,
        rmtyp_description: "Classroom",
        facility_code_heprod: "LAW2171"
      )
      other = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 2_324_311,
        rmtyp_description: "Classroom",
        facility_code_heprod: "LAW2172"
      )
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 42, chrstc_descrshort: "ProjDigit")
      create(:room_characteristic, rmrecnbr: room.rmrecnbr, chrstc: 99, chrstc_descrshort: "VCR")
      api = described_class.new
      stub_characteristics(
        api,
        "LAW2171" => [
          characteristic_row(room.rmrecnbr, 42),
          characteristic_row(room.rmrecnbr, "42")
        ],
        "LAW2172" => [characteristic_row(other.rmrecnbr, 7, short_code: nil)]
      )

      expect(api.update_all_classroom_characteristics).to be(false)
      expect(api.last_result).to be_success
      expect(RoomCharacteristic.where(rmrecnbr: room.rmrecnbr).pluck(:chrstc)).to contain_exactly(42)
      expect(RoomCharacteristic.find_by(rmrecnbr: other.rmrecnbr, chrstc: 7).chrstc_descrshort).to eq("")
    end
  end

  describe "#deactivate_stale_rooms" do
    it "hides a classroom whose visibility is unset" do
      building = create(:building, bldrecnbr: 5_000_208)
      room = create(
        :room,
        building_bldrecnbr: building.bldrecnbr,
        rmrecnbr: 1_400_208,
        rmtyp_description: "Classroom",
        visible: nil
      )
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr])

      expect(api.send(:deactivate_stale_rooms, "add_facility_id_to_classrooms")).to eq(1)
      expect(room.reload.visible).to be(false)
    end
  end
end
