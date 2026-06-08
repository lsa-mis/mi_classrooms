require "rails_helper"

RSpec.describe BuildingsApi do
  describe "#update_all_buildings" do
    it "does not error when the API returns the same building twice" do
      campus = CampusRecord.create!(campus_cd: 100, campus_description: "Ann Arbor")
      building = create(:building, bldrecnbr: 5_000_401, zip: "48109", campus_record: campus)
      row = {
        "BuildingRecordNumber" => building.bldrecnbr.to_s,
        "BuildingLongDescription" => "Updated Name",
        "BuildingShortDescription" => "UN",
        "BuildingStreetNumber" => "1",
        "BuildingStreetDirection" => "",
        "BuildingStreetName" => "Main St",
        "BuildingCity" => "Ann Arbor",
        "BuildingState" => "MI",
        "BuildingPostal" => "48109",
        "BuildingCampusCode" => campus.campus_cd.to_s
      }
      api = described_class.new
      allow(api).to receive(:get_buildings_for_current_fiscal_year).and_return(
        {"success" => true, "data" => [row, row]}
      )

      api.update_all_buildings

      expect(api.last_result.success?).to be(true)
      expect(building.reload.name).to eq("Updated Name")
    end
  end

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

  describe "#deactivate_stale_rooms" do
    it "rolls back deactivation when every requested room is not deactivated" do
      building = create(:building, bldrecnbr: 5_000_302)
      room = create(:room, building_bldrecnbr: building.bldrecnbr, rmrecnbr: 1_500_302)
      contact = RoomContact.create!(rmrecnbr: room.rmrecnbr)
      characteristic = create(:room_characteristic, rmrecnbr: room.rmrecnbr)
      api = described_class.new
      api.instance_variable_set(:@rooms_in_db, [room.rmrecnbr, 9_999_999])

      expect(api.send(:deactivate_stale_rooms, "update_rooms")).to be(false)
      expect(Room.exists?(room.rmrecnbr)).to be(true)
      expect(RoomContact.exists?(contact.id)).to be(true)
      expect(RoomCharacteristic.exists?(characteristic.id)).to be(true)
    end
  end

  describe "#department_error_guidance" do
    let(:api) { described_class.new }

    it "explains rate limiting for a 429 status code" do
      expect(api.send(:department_error_guidance, "HTTP 429")).to match(/Rate limited/i)
    end

    it "explains a missing department for a 404 status code" do
      expect(api.send(:department_error_guidance, "HTTP 404")).to match(/not found/i)
    end

    it "explains an authorization failure for 401, 403, and AuthTokenError" do
      expect(api.send(:department_error_guidance, "HTTP 401")).to match(/Authorization failed/i)
      expect(api.send(:department_error_guidance, "HTTP 403")).to match(/Authorization failed/i)
      expect(api.send(:department_error_guidance, "AuthTokenError")).to match(/Authorization failed/i)
    end

    it "explains a transient server error for 5xx, Exception, and Fault" do
      expect(api.send(:department_error_guidance, "HTTP 500")).to match(/server error/i)
      expect(api.send(:department_error_guidance, "Exception")).to match(/server error/i)
      expect(api.send(:department_error_guidance, "Fault")).to match(/server error/i)
    end

    it "gives a generic fallback for an unrecognized error code" do
      expect(api.send(:department_error_guidance, "Unknown error")).to match(/Unrecognized API response/i)
      expect(api.send(:department_error_guidance, "")).to match(/Unrecognized API response/i)
    end
  end
end
