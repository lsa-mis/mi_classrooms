require "rails_helper"

RSpec.describe RoomDecorator do
  let(:building) do
    create(:building, name: "mason hall", address: "419 state street", city: "ann arbor")
  end
  let(:room) do
    create(
      :room,
      building_bldrecnbr: building.bldrecnbr,
      room_number: "1400",
      instructional_seating_count: 120
    )
  end
  let(:decorator) { described_class.decorate(room) }

  describe "#title" do
    it "includes room number and titleized building name" do
      expect(decorator.title).to eq("1400 Mason Hall")
    end
  end

  describe "#address" do
    it "formats a titleized address string" do
      expect(decorator.address).to include("419 State Street, Ann Arbor")
    end
  end

  describe "#student_capacity" do
    it "pluralizes student count" do
      expect(decorator.student_capacity).to eq("120 Students")
    end
  end

  describe "contact fields" do
    it "returns fallback values when contact data is absent" do
      expect(decorator.room_schedule_contact).to eq("Contact Not Available")
      expect(decorator.room_schedule_email).to eq("Not Available")
      expect(decorator.room_schedule_phone).to eq("Not Available")
      expect(decorator.room_support_email).to eq("Not Available")
      expect(decorator.room_support_phone).to eq("Not Available")
      expect(decorator.room_support_url).to eq("Not Available")
    end

    it "returns normalized values when contact data exists" do
      RoomContact.create!(
        rmrecnbr: room.rmrecnbr,
        rm_schd_cntct_name: "jane doe",
        rm_schd_email: "JDOE@UMICH.EDU",
        rm_schd_cntct_phone: "734-555-1111",
        rm_sppt_cntct_email: "help@umich.edu",
        rm_sppt_cntct_phone: "734-555-2222",
        rm_sppt_cntct_url: "https://support.umich.edu"
      )

      expect(decorator.room_schedule_contact).to eq("Jane Doe")
      expect(decorator.room_schedule_email).to eq("jdoe@umich.edu")
      expect(decorator.room_schedule_phone).to eq("734-555-1111")
      expect(decorator.room_support_email).to eq("help@umich.edu")
      expect(decorator.room_support_phone).to eq("734-555-2222")
      expect(decorator.room_support_url).to eq("https://support.umich.edu")
    end
  end
end
